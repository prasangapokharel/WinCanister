import Principal "mo:core/Principal";
import Nat "mo:core/Nat";
import Text "mo:core/Text";
import Array "mo:core/Array";
import RoundRepository "../repositories/RoundRepository";
import WinnerRepository "../repositories/WinnerRepository";
import PayoutRepository "../repositories/PayoutRepository";
import StatisticsRepository "../repositories/StatisticsRepository";
import ConfigRepository "../repositories/ConfigRepository";
import PayoutRecord "../models/PayoutRecord";
import Winner "../models/Winner";
import AddressEntryRepository "../repositories/AddressEntryRepository";
import AccountIdentifier "../utils/AccountIdentifier";
import AccountParticipant "../utils/AccountParticipant";
import PublicCurrentRoundResponse "../dto/PublicCurrentRoundResponse";
import RoundResultResponse "../dto/RoundResultResponse";
import PayoutDetailsResponse "../dto/PayoutDetailsResponse";
import PublicStatisticsResponse "../dto/PublicStatisticsResponse";
import WinnerHistoryResponse "../dto/WinnerHistoryResponse";
import TimeUtil "../utils/TimeUtil";

module {
  public class Service(
    roundRepo : RoundRepository.Repository,
    winnerRepo : WinnerRepository.Repository,
    addressEntryRepo : AddressEntryRepository.Repository,
    payoutRepo : PayoutRepository.Repository,
    statisticsRepo : StatisticsRepository.Repository,
    _configRepo : ConfigRepository.Repository,
  ) {
    public func getCurrentRoundPublic() : ?PublicCurrentRoundResponse.PublicCurrentRoundResponse {
      let roundId = roundRepo.getCurrentRoundId();
      switch (roundRepo.findById(roundId)) {
        case null null;
        case (?round) ?PublicCurrentRoundResponse.fromRound(round);
      };
    };

    public func getRoundResult(roundId : Nat) : ?RoundResultResponse.RoundResultResponse {
      switch (roundRepo.findById(roundId)) {
        case null null;
        case (?round) {
          let winners = winnerRepo.getByRound(roundId);
          ?RoundResultResponse.fromRoundAndWinners(round, winners);
        };
      };
    };

    public func getPayouts(roundId : Nat) : ?PayoutDetailsResponse.PayoutDetailsResponse {
      switch (roundRepo.findById(roundId)) {
        case null null;
        case (?_) {
          let payouts = payoutRepo.getByRound(roundId);
          let winners = winnerRepo.getByRound(roundId);
          let addressHexes = addressEntryRepo.getAccountHexesByRound(roundId);
          ?{
            roundId = roundId;
            winner1 = payoutEntryForPosition(payouts, winners, addressHexes, 1);
            winner2 = payoutEntryForPosition(payouts, winners, addressHexes, 2);
            winner3 = payoutEntryForPosition(payouts, winners, addressHexes, 3);
            treasury = treasuryPayoutEntry(payouts);
          };
        };
      };
    };

    public func getPublicStatistics() : PublicStatisticsResponse.PublicStatisticsResponse {
      PublicStatisticsResponse.fromStatistics(statisticsRepo.get());
    };

    public func getWinnerHistory() : [WinnerHistoryResponse.WinnerHistoryEntry] {
      let history = roundRepo.getHistory();
      Array.map<Nat, WinnerHistoryResponse.WinnerHistoryEntry>(
        history,
        func(roundId) {
          WinnerHistoryResponse.fromWinners(roundId, winnerRepo.getByRound(roundId));
        },
      );
    };

    public func recordWinnerPayout(
      roundId : Nat,
      position : Nat,
      recipient : Principal,
      amount : Nat,
      ledgerTxId : Nat,
    ) {
      ignore payoutRepo.save(
        PayoutRecord.newWinnerPayout(
          roundId,
          position,
          recipient,
          amount,
          ledgerTxId,
          TimeUtil.now(),
        ),
      );
    };

    public func recordTreasuryPayout(
      roundId : Nat,
      recipient : Principal,
      amount : Nat,
      ledgerTxId : Nat,
    ) {
      ignore payoutRepo.save(
        PayoutRecord.newTreasuryPayout(
          roundId,
          recipient,
          amount,
          ledgerTxId,
          TimeUtil.now(),
        ),
      );
    };

    func payoutEntryForPosition(
      payouts : [PayoutRecord.PayoutRecord],
      winners : [Winner.Winner],
      addressHexes : [Text],
      position : Nat,
    ) : ?PayoutDetailsResponse.PayoutEntryResponse {
      switch (findWinner(winners, position)) {
        case null null;
        case (?winner) {
          let accountHex = AccountParticipant.payoutAccountHex(winner.participant, addressHexes);
          switch (findPayoutForWinner(payouts, position)) {
            case (?payout) {
              ?{
                accountHex = accountHex;
                amount = winner.prizeAmount;
                txId = payout.ledgerTxId;
                paid = winner.paid;
              };
            };
            case null {
              ?{
                accountHex = accountHex;
                amount = winner.prizeAmount;
                txId = switch (winner.blockIndex) { case (?id) id; case null 0 };
                paid = winner.paid;
              };
            };
          };
        };
      };
    };

    func treasuryPayoutEntry(payouts : [PayoutRecord.PayoutRecord]) : ?PayoutDetailsResponse.PayoutEntryResponse {
      for (payout in payouts.vals()) {
        switch (payout.kind) {
          case (#Treasury) {
            return ?{
              accountHex = AccountIdentifier.toHex(payout.recipient);
              amount = payout.amount;
              txId = payout.ledgerTxId;
              paid = true;
            };
          };
          case (#Winner) {};
        };
      };
      null;
    };

    func findWinner(winners : [Winner.Winner], position : Nat) : ?Winner.Winner {
      for (winner in winners.vals()) {
        if (winner.position == position) {
          return ?winner;
        };
      };
      null;
    };

    func findPayoutForWinner(payouts : [PayoutRecord.PayoutRecord], position : Nat) : ?PayoutRecord.PayoutRecord {
      for (payout in payouts.vals()) {
        switch (payout.kind) {
          case (#Winner) {
            switch (payout.position) {
              case (?pos) {
                if (pos == position) {
                  return ?payout;
                };
              };
              case null {};
            };
          };
          case (#Treasury) {};
        };
      };
      null;
    };
  };
};
