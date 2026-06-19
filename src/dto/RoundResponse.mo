import Nat "mo:core/Nat";
import Round "../models/Round";

module {
  public type RoundResponse = {
    id : Nat;
    status : Round.RoundStatus;
    startTime : Int;
    endTime : Int;
    totalCollected : Nat;
    entryCount : Nat;
    prizePool : Nat;
    treasuryFee : Nat;
    unclaimedTreasury : Nat;
    treasuryTransferred : Bool;
    payoutCompleted : Bool;
  };

  public func fromRound(round : Round.Round) : RoundResponse {
    {
      id = round.id;
      status = round.status;
      startTime = round.startTime;
      endTime = round.endTime;
      totalCollected = round.totalCollected;
      entryCount = round.entryCount;
      prizePool = round.prizePool;
      treasuryFee = round.treasuryFee;
      unclaimedTreasury = round.unclaimedTreasury;
      treasuryTransferred = round.treasuryTransferred;
      payoutCompleted = round.payoutCompleted;
    };
  };
};
