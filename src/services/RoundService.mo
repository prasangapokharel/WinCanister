import Principal "mo:core/Principal";
import Nat "mo:core/Nat";
import Text "mo:core/Text";
import Result "mo:core/Result";
import Blob "mo:core/Blob";
import RoundRepository "../repositories/RoundRepository";
import EntryRepository "../repositories/EntryRepository";
import AddressEntryRepository "../repositories/AddressEntryRepository";
import WinnerRepository "../repositories/WinnerRepository";
import Array "mo:core/Array";
import AccountIdentifier "../utils/AccountIdentifier";
import AccountParticipant "../utils/AccountParticipant";
import StatisticsRepository "../repositories/StatisticsRepository";
import Round "../models/Round";
import Winner "../models/Winner";
import RoundValidator "../validators/RoundValidator";
import PaymentValidator "../validators/PaymentValidator";
import AppConfig "../config/AppConfig";
import TimeUtil "../utils/TimeUtil";
import Logger "../utils/Logger";
import TreasuryService "TreasuryService";
import WinnerService "WinnerService";
import PrizeService "PrizeService";
import ConfigService "ConfigService";
import TransparencyService "TransparencyService";

module {
  public type LedgerPort = {
    transfer : (Principal, Nat, ?Blob) -> async Result.Result<Nat, Text>;
    transferToAccountHex : (Text, Nat, ?Blob) -> async Result.Result<Nat, Text>;
  };

  public class Service(
    roundRepo : RoundRepository.Repository,
    entryRepo : EntryRepository.Repository,
    addressEntryRepo : AddressEntryRepository.Repository,
    winnerRepo : WinnerRepository.Repository,
    statisticsRepo : StatisticsRepository.Repository,
    treasuryService : TreasuryService.Service,
    configService : ConfigService.Service,
    transparencyService : TransparencyService.Service,
    winnerService : WinnerService.Service,
    ledger : LedgerPort,
  ) {
    public func createInitialRound() {
      if (roundRepo.getCurrentRoundId() > 0) {
        return;
      };
      ignore createNextRound();
    };

    public func createNextRound() : Nat {
      let nextId = roundRepo.getCurrentRoundId() + 1;
      let startTime = TimeUtil.now();
      let endTime = TimeUtil.endTime(startTime, AppConfig.ROUND_DURATION_NS);
      let round = Round.newRound(nextId, startTime, endTime);
      roundRepo.save(round);
      roundRepo.setCurrentRoundId(nextId);
      let stats = statisticsRepo.get();
      statisticsRepo.set({ stats with totalRounds = stats.totalRounds + 1 });
      Logger.event("round_created", Nat.toText(nextId));
      nextId;
    };

    public func getCurrentRound() : ?Round.Round {
      roundRepo.findById(roundRepo.getCurrentRoundId());
    };

    public func closeRoundIfExpired() : async Result.Result<Text, Text> {
      switch (getCurrentRound()) {
        case null #err("no_active_round");
        case (?round) {
          switch (RoundValidator.validateCanClose(round)) {
            case (?err) #err(err);
            case null {
              let closed = { round with status = #RoundClose };
              roundRepo.save(closed);
              Logger.event("round_closed", Nat.toText(round.id));
              #ok("round_closed");
            };
          };
        };
      };
    };

    public func drawWinners() : async Result.Result<Text, Text> {
      switch (getCurrentRound()) {
        case null return #err("no_active_round");
        case (?round) {
          switch (RoundValidator.validateCanDraw(round)) {
            case (?err) return #err(err);
            case null {};
          };

          let principalHexes = Array.map<Principal, Text>(
            entryRepo.getParticipantsByRound(round.id),
            AccountIdentifier.toHex,
          );
          let participants = Array.concat(
            principalHexes,
            addressEntryRepo.getAccountHexesByRound(round.id),
          );
          switch (await winnerService.selectWinners(participants)) {
            case (#err(msg)) return #err(msg);
            case (#ok(selections)) {
              let breakdown = PrizeService.calculatePrizeBreakdown(round.prizePool, selections.size());

              for (selection in selections.vals()) {
                let prizeAmount = PrizeService.getPrizeForPosition(breakdown, selection.position);
                let winner = Winner.newWinner(
                  round.id,
                  selection.position,
                  AccountParticipant.syntheticPrincipalFromAccountHex(selection.accountHex),
                  prizeAmount,
                );
                winnerRepo.save(winner);
              };

              let stats = statisticsRepo.get();
              statisticsRepo.set({
                stats with totalWinners = stats.totalWinners + selections.size();
              });

              let updated = {
                round with
                status = #DrawWinners;
                unclaimedTreasury = breakdown.treasuryFromUnclaimed;
              };
              roundRepo.save(updated);
              Logger.event("winners_drawn", Nat.toText(selections.size()));
              #ok("winners_drawn");
            };
          };
        };
      };
    };

    public func transferTreasuryFees() : async Result.Result<Text, Text> {
      switch (getCurrentRound()) {
        case null return #err("no_active_round");
        case (?round) {
          if (round.treasuryTransferred) {
            return #err("treasury_already_transferred");
          };
          switch (RoundValidator.validateCanDistribute(round)) {
            case (?err) return #err(err);
            case null {};
          };
          let grossTreasury = round.treasuryFee + round.unclaimedTreasury;
          // The ledger charges LEDGER_TRANSFER_FEE on top of the amount, so the
          // recipient bears the fee: send (gross - fee). If the gross can't cover
          // the fee there is nothing meaningful to send; mark transferred to advance.
          if (grossTreasury <= AppConfig.LEDGER_TRANSFER_FEE) {
            let advanced = { round with treasuryTransferred = true };
            roundRepo.save(advanced);
            Logger.event("round_treasury_skipped", Nat.toText(grossTreasury));
            return #ok("treasury_skipped");
          };
          let netTreasury = grossTreasury - AppConfig.LEDGER_TRANSFER_FEE;
          let treasuryPrincipal = configService.getTreasuryPrincipal();
          switch (await treasuryService.transferTreasury(ledger, treasuryPrincipal, netTreasury)) {
            case (#err(msg)) return #err(msg);
            case (#ok(blockIndex)) {
              transparencyService.recordTreasuryPayout(
                round.id,
                treasuryPrincipal,
                netTreasury,
                blockIndex,
              );
              let updated = {
                round with treasuryTransferred = true;
              };
              roundRepo.save(updated);
              Logger.event("round_treasury_transferred", Nat.toText(netTreasury));
              #ok("treasury_transferred");
            };
          };
        };
      };
    };

    public func distributePrizes() : async Result.Result<Text, Text> {
      switch (getCurrentRound()) {
        case null return #err("no_active_round");
        case (?round) {
          if (not round.treasuryTransferred and round.entryCount > 0) {
            return #err("treasury_not_transferred");
          };
          switch (RoundValidator.validateCanDistribute(round)) {
            case (?err) return #err(err);
            case null {};
          };

          let winners = winnerRepo.getByRound(round.id);
          var totalPaid : Nat = 0;

          let addressHexes = addressEntryRepo.getAccountHexesByRound(round.id);
          for (winner in winners.vals()) {
            // Skip winners already paid so a partial distribution can resume cleanly.
            if (not winner.paid) {
              switch (PaymentValidator.validatePayoutAmount(winner.prizeAmount)) {
                case (?err) return #err(err);
                case null {};
              };
              // Recipient bears the ledger fee: send (prize - fee). A prize that
              // can't cover the fee is unpayable; mark it settled and skip.
              if (winner.prizeAmount <= AppConfig.LEDGER_TRANSFER_FEE) {
                let settled = { winner with paid = true; blockIndex = null };
                winnerRepo.save(settled);
              } else {
                let netAmount = winner.prizeAmount - AppConfig.LEDGER_TRANSFER_FEE;
                let payoutHex = AccountParticipant.payoutAccountHex(winner.participant, addressHexes);
                switch (await ledger.transferToAccountHex(payoutHex, netAmount, null)) {
                  case (#err(msg)) return #err(msg);
                  case (#ok(blockIndex)) {
                    transparencyService.recordWinnerPayout(
                      round.id,
                      winner.position,
                      winner.participant,
                      netAmount,
                      blockIndex,
                    );
                    let paidWinner = {
                      winner with
                      paid = true;
                      blockIndex = ?blockIndex;
                    };
                    winnerRepo.save(paidWinner);
                    totalPaid += winner.prizeAmount;
                  };
                };
              };
            };
          };

          switch (PaymentValidator.validateSufficientPool(round.prizePool, totalPaid)) {
            case (?err) return #err(err);
            case null {};
          };

          let stats = statisticsRepo.get();
          statisticsRepo.set({
            stats with totalPrizesPaid = stats.totalPrizesPaid + totalPaid;
          });

          let distributed = { round with status = #DistributePrizes };
          roundRepo.save(distributed);
          Logger.event("prizes_distributed", Nat.toText(totalPaid));
          #ok("prizes_distributed");
        };
      };
    };

    public func archiveRound() : Result.Result<Text, Text> {
      switch (getCurrentRound()) {
        case null #err("no_active_round");
        case (?round) {
          if (round.entryCount > 0 and round.status != #DistributePrizes) {
            return #err("round_not_ready_for_archive");
          };
          let archived = {
            round with
            status = #Completed;
            payoutCompleted = true;
          };
          roundRepo.save(archived);
          roundRepo.addToHistory(round.id);
          Logger.event("round_archived", Nat.toText(round.id));
          #ok("round_archived");
        };
      };
    };

    // Idempotent and resumable: each step is gated on the round's current status
    // and the round is re-read between steps, so a round left stuck in any
    // intermediate state (e.g. #DrawWinners after a failed payout) is picked up
    // and driven to completion on the next call instead of deadlocking.
    public func processExpiredRound() : async Result.Result<Text, Text> {
      // Step 1 — close the round once it has expired.
      switch (getCurrentRound()) {
        case null return #err("no_active_round");
        case (?round) {
          if (Round.isAcceptingEntries(round)) {
            if (not RoundValidator.validateRoundExpired(round)) {
              return #err("round_not_expired");
            };
            switch (await closeRoundIfExpired()) {
              case (#err(msg)) return #err(msg);
              case (#ok(_)) {};
            };
          };
        };
      };

      // Step 2 — draw winners.
      switch (getCurrentRound()) {
        case null return #err("no_active_round");
        case (?round) {
          if (round.status == #RoundClose) {
            switch (await drawWinners()) {
              case (#err(msg)) return #err(msg);
              case (#ok(_)) {};
            };
          };
        };
      };

      // Step 3 — empty round: nothing to pay out, archive and roll over.
      switch (getCurrentRound()) {
        case null return #err("no_active_round");
        case (?round) {
          if (round.entryCount == 0 and (round.status == #RoundClose or round.status == #DrawWinners)) {
            switch (archiveRound()) {
              case (#err(msg)) return #err(msg);
              case (#ok(_)) {};
            };
            ignore createNextRound();
            return #ok("empty_round_archived");
          };
        };
      };

      // Step 4 — transfer treasury fees (only if not already done).
      switch (getCurrentRound()) {
        case null return #err("no_active_round");
        case (?round) {
          if (round.status == #DrawWinners and not round.treasuryTransferred) {
            switch (await transferTreasuryFees()) {
              case (#err(msg)) return #err(msg);
              case (#ok(_)) {};
            };
          };
        };
      };

      // Step 5 — distribute prizes.
      switch (getCurrentRound()) {
        case null return #err("no_active_round");
        case (?round) {
          if (round.status == #DrawWinners) {
            switch (await distributePrizes()) {
              case (#err(msg)) return #err(msg);
              case (#ok(_)) {};
            };
          };
        };
      };

      // Step 6 — archive and open the next round.
      switch (getCurrentRound()) {
        case null return #err("no_active_round");
        case (?round) {
          if (round.status == #DistributePrizes) {
            switch (archiveRound()) {
              case (#err(msg)) return #err(msg);
              case (#ok(_)) {};
            };
            ignore createNextRound();
            return #ok("round_processed");
          };
        };
      };

      #ok("round_processed");
    };
  };
};
