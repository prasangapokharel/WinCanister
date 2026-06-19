import Nat "mo:core/Nat";
import TransparencyService "../../services/TransparencyService";
import PublicCurrentRoundResponse "../../dto/PublicCurrentRoundResponse";
import RoundResultResponse "../../dto/RoundResultResponse";
import PayoutDetailsResponse "../../dto/PayoutDetailsResponse";
import PublicStatisticsResponse "../../dto/PublicStatisticsResponse";
import WinnerHistoryResponse "../../dto/WinnerHistoryResponse";

module {
  public class Controller(transparencyService : TransparencyService.Service) {
    public func getCurrentRound() : ?PublicCurrentRoundResponse.PublicCurrentRoundResponse {
      transparencyService.getCurrentRoundPublic();
    };

    public func getRoundResult(roundId : Nat) : ?RoundResultResponse.RoundResultResponse {
      transparencyService.getRoundResult(roundId);
    };

    public func getPayouts(roundId : Nat) : ?PayoutDetailsResponse.PayoutDetailsResponse {
      transparencyService.getPayouts(roundId);
    };

    public func getStatistics() : PublicStatisticsResponse.PublicStatisticsResponse {
      transparencyService.getPublicStatistics();
    };

    public func getWinnerHistory() : [WinnerHistoryResponse.WinnerHistoryEntry] {
      transparencyService.getWinnerHistory();
    };
  };
};
