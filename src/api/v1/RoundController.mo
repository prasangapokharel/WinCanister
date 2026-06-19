import Result "mo:core/Result";
import Nat "mo:core/Nat";
import LotteryService "../../services/LotteryService";
import RoundResponse "../../dto/RoundResponse";

module {
  public class Controller(lotteryService : LotteryService.Service) {
    public func getCurrentRound() : ?RoundResponse.RoundResponse {
      switch (lotteryService.getCurrentRound()) {
        case null null;
        case (?round) ?RoundResponse.fromRound(round);
      };
    };

    public func getRoundHistory() : [Nat] {
      lotteryService.getRoundHistory();
    };

    public func processExpiredRound() : async Result.Result<Text, Text> {
      await lotteryService.processExpiredRound();
    };
  };
};
