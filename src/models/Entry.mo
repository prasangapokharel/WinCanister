import Principal "mo:core/Principal";
import Nat "mo:core/Nat";

module {
  public type Entry = {
    roundId : Nat;
    participant : Principal;
    amount : Nat;
    timestamp : Int;
  };

  public func newEntry(roundId : Nat, participant : Principal, amount : Nat, timestamp : Int) : Entry {
    {
      roundId = roundId;
      participant = participant;
      amount = amount;
      timestamp = timestamp;
    };
  };
};
