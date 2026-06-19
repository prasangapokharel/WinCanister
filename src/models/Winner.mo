import Principal "mo:core/Principal";
import Nat "mo:core/Nat";

module {
  public type Winner = {
    roundId : Nat;
    position : Nat;
    participant : Principal;
    prizeAmount : Nat;
    paid : Bool;
    blockIndex : ?Nat;
  };

  public func newWinner(
    roundId : Nat,
    position : Nat,
    participant : Principal,
    prizeAmount : Nat,
  ) : Winner {
    {
      roundId = roundId;
      position = position;
      participant = participant;
      prizeAmount = prizeAmount;
      paid = false;
      blockIndex = null;
    };
  };
};
