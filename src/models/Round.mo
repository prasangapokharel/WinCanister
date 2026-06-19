import Principal "mo:core/Principal";
import Nat "mo:core/Nat";

module {
  public type RoundStatus = {
    #Open;
    #AcceptEntries;
    #RoundClose;
    #DrawWinners;
    #DistributePrizes;
    #ArchiveRound;
    #Completed;
  };

  public type Round = {
    id : Nat;
    status : RoundStatus;
    startTime : Int;
    endTime : Int;
    totalCollected : Nat;
    entryCount : Nat;
    treasuryFee : Nat;
    prizePool : Nat;
    unclaimedTreasury : Nat;
    treasuryTransferred : Bool;
    payoutCompleted : Bool;
  };

  public func newRound(id : Nat, startTime : Int, endTime : Int) : Round {
    {
      id = id;
      status = #AcceptEntries;
      startTime = startTime;
      endTime = endTime;
      totalCollected = 0;
      entryCount = 0;
      treasuryFee = 0;
      prizePool = 0;
      unclaimedTreasury = 0;
      treasuryTransferred = false;
      payoutCompleted = false;
    };
  };

  public func isAcceptingEntries(round : Round) : Bool {
    round.status == #Open or round.status == #AcceptEntries;
  };

  public func isActive(round : Round) : Bool {
    switch (round.status) {
      case (#Completed) false;
      case (#ArchiveRound) false;
      case (_) true;
    };
  };
};
