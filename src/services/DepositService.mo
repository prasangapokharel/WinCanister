import Principal "mo:core/Principal";
import Nat "mo:core/Nat";
import Nat64 "mo:core/Nat64";
import Blob "mo:core/Blob";
import Text "mo:core/Text";
import Result "mo:core/Result";
import EntryRepository "../repositories/EntryRepository";
import AddressEntryRepository "../repositories/AddressEntryRepository";
import RoundRepository "../repositories/RoundRepository";
import StatisticsRepository "../repositories/StatisticsRepository";
import ProcessedDepositRepository "../repositories/ProcessedDepositRepository";
import ConfigRepository "../repositories/ConfigRepository";
import IndexPort "../ledger/IndexPort";
import AddressEntry "../models/AddressEntry";
import EntryValidator "../validators/EntryValidator";
import TimeUtil "../utils/TimeUtil";
import Helpers "../utils/Helpers";
import Logger "../utils/Logger";
import AccountIdentifier "../utils/AccountIdentifier";
import AppConfig "../config/AppConfig";
import TreasuryService "TreasuryService";

module {
  public type LedgerPort = {
    transfer : (Principal, Nat, ?Blob) -> async Result.Result<Nat, Text>;
  };

  public class Service(
    entryRepo : EntryRepository.Repository,
    addressEntryRepo : AddressEntryRepository.Repository,
    roundRepo : RoundRepository.Repository,
    statisticsRepo : StatisticsRepository.Repository,
    processedDepositRepo : ProcessedDepositRepository.Repository,
    configRepo : ConfigRepository.Repository,
    treasuryService : TreasuryService.Service,
    indexPort : IndexPort.Port,
    canisterPrincipal : Principal,
  ) {
    func creditAddressEntry(
      accountHex : Text,
      amount : Nat,
      roundId : Nat,
      txId : Nat64,
      timestampNanos : ?Nat,
    ) : Result.Result<Nat, Text> {
      switch (roundRepo.findById(roundId)) {
        case null return #err("no_active_round");
        case (?round) {
          // Prefer the ledger transaction time; fall back to processing time.
          let depositTime : Int = switch (timestampNanos) {
            case (?ns) ns;
            case null TimeUtil.now();
          };
          let entry = AddressEntry.newAddressEntry(
            roundId,
            accountHex,
            amount,
            depositTime,
            txId,
          );
          addressEntryRepo.save(entry);

          let treasuryFee = Helpers.calculateTreasuryFee(amount);
          let prizeContribution = amount - treasuryFee;
          treasuryService.recordAccruedFee(amount);

          let updatedRound = {
            round with
            totalCollected = round.totalCollected + amount;
            entryCount = round.entryCount + 1;
            treasuryFee = round.treasuryFee + treasuryFee;
            prizePool = round.prizePool + prizeContribution;
          };
          roundRepo.save(updatedRound);

          let stats = statisticsRepo.get();
          statisticsRepo.set({
            stats with totalEntries = stats.totalEntries + 1;
          });

          Logger.event("deposit_credited", accountHex);
          #ok(roundId);
        };
      };
    };

    func isAccountInRound(roundId : Nat, accountHex : Text) : Bool {
      switch (addressEntryRepo.findByRoundAndAccountHex(roundId, accountHex)) {
        case (?_) true;
        case null {
          for (participant in entryRepo.getParticipantsByRound(roundId).vals()) {
            if (AccountIdentifier.toHex(participant) == accountHex) {
              return true;
            };
          };
          false;
        };
      };
    };

    public func processIncomingDeposits() : async Nat {
      let roundId = roundRepo.getCurrentRoundId();
      switch (roundRepo.findById(roundId)) {
        case null return 0;
        case (?round) {
          switch (EntryValidator.validateRoundAcceptingEntries(round)) {
            case (?_) return 0;
            case null {};
          };
        };
      };

      switch (
        await indexPort.getIncomingTransfers(canisterPrincipal, Nat64.fromNat(50))
      ) {
        case (#err(_)) 0;
        case (#ok(transfers)) {
          var credited : Nat = 0;
          for (transfer in transfers.vals()) {
            if (
              transfer.amountE8s >= AppConfig.MIN_ENTRY_AMOUNT
              and AccountIdentifier.isValidHex(transfer.fromAccountHex)
              and not processedDepositRepo.isProcessed(transfer.txId)
              and not isAccountInRound(roundId, transfer.fromAccountHex)
            ) {
              switch (
                creditAddressEntry(
                  transfer.fromAccountHex,
                  transfer.amountE8s,
                  roundId,
                  transfer.txId,
                  transfer.timestampNanos,
                )
              ) {
                case (#ok(_)) {
                  processedDepositRepo.markProcessed(transfer.txId);
                  credited += 1;
                };
                case (#err(_)) {};
              };
            };
          };
          credited;
        };
      };
    };

    public func adminRefundIcp(
      caller : Principal,
      recipient : Principal,
      amount : Nat,
      voidDepositTxId : ?Nat64,
      ledger : LedgerPort,
    ) : async Result.Result<Nat, Text> {
      let config = configRepo.get();
      if (not Principal.equal(caller, config.adminPrincipal)) {
        return #err("admin_only");
      };
      if (Principal.isAnonymous(recipient)) {
        return #err("invalid_recipient");
      };
      if (amount == 0) {
        return #err("invalid_amount");
      };
      switch (await ledger.transfer(recipient, amount, null)) {
        case (#err(msg)) #err(msg);
        case (#ok(txId)) {
          switch (voidDepositTxId) {
            case (?depositTxId) {
              processedDepositRepo.markProcessed(depositTxId);
            };
            case null {};
          };
          Logger.event("admin_refund", Principal.toText(recipient));
          #ok(txId);
        };
      };
    };

    public func getUnclaimedIncomingTotal() : async Nat {
      switch (
        await indexPort.getIncomingTransfers(canisterPrincipal, Nat64.fromNat(50))
      ) {
        case (#err(_)) 0;
        case (#ok(transfers)) {
          var total : Nat = 0;
          for (transfer in transfers.vals()) {
            if (
              transfer.amountE8s >= AppConfig.MIN_ENTRY_AMOUNT
              and not processedDepositRepo.isProcessed(transfer.txId)
            ) {
              total += transfer.amountE8s;
            };
          };
          total;
        };
      };
    };
  };
};
