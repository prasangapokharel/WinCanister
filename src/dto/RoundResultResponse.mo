import Principal "mo:core/Principal";
import Nat "mo:core/Nat";
import Text "mo:core/Text";
import Round "../models/Round";
import Winner "../models/Winner";
import PublicCurrentRoundResponse "PublicCurrentRoundResponse";

module {
  public type RoundResultResponse = {
    roundId : Nat;
    totalPool : Nat;
    treasuryFee : Nat;
    prizePool : Nat;
    winner1 : ?Principal;
    winner2 : ?Principal;
    winner3 : ?Principal;
    status : Text;
  };

  public func fromRoundAndWinners(round : Round.Round, winners : [Winner.Winner]) : RoundResultResponse {
    {
      roundId = round.id;
      totalPool = round.totalCollected;
      treasuryFee = round.treasuryFee + round.unclaimedTreasury;
      prizePool = round.prizePool;
      winner1 = findWinnerPrincipal(winners, 1);
      winner2 = findWinnerPrincipal(winners, 2);
      winner3 = findWinnerPrincipal(winners, 3);
      status = PublicCurrentRoundResponse.statusToText(round.status);
    };
  };

  func findWinnerPrincipal(winners : [Winner.Winner], position : Nat) : ?Principal {
    for (winner in winners.vals()) {
      if (winner.position == position) {
        return ?winner.participant;
      };
    };
    null;
  };
};
