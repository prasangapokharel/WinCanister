import Principal "mo:core/Principal";
import Nat "mo:core/Nat";
import Winner "../models/Winner";

module {
  public type WinnerResponse = {
    roundId : Nat;
    position : Nat;
    participant : Principal;
    prizeAmount : Nat;
    paid : Bool;
  };

  public func fromWinner(winner : Winner.Winner) : WinnerResponse {
    {
      roundId = winner.roundId;
      position = winner.position;
      participant = winner.participant;
      prizeAmount = winner.prizeAmount;
      paid = winner.paid;
    };
  };
};
