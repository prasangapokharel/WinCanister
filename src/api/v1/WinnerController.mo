import Nat "mo:core/Nat";
import Array "mo:core/Array";
import LotteryService "../../services/LotteryService";
import WinnerResponse "../../dto/WinnerResponse";
import Winner "../../models/Winner";

module {
  public class Controller(lotteryService : LotteryService.Service) {
    public func getWinnersByRound(roundId : Nat) : [WinnerResponse.WinnerResponse] {
      let winners = lotteryService.getWinnersByRound(roundId);
      Array.map<Winner.Winner, WinnerResponse.WinnerResponse>(
        winners,
        WinnerResponse.fromWinner,
      );
    };
  };
};
