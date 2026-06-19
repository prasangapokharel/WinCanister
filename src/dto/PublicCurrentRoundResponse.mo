import Round "../models/Round";

module {
  public type PublicCurrentRoundResponse = {
    roundId : Nat;
    startTime : Int;
    endTime : Int;
    participants : Nat;
    poolICP : Nat;
    status : Text;
  };

  public func fromRound(round : Round.Round) : PublicCurrentRoundResponse {
    {
      roundId = round.id;
      startTime = round.startTime;
      endTime = round.endTime;
      participants = round.entryCount;
      poolICP = round.totalCollected;
      status = statusToText(round.status);
    };
  };

  public func statusToText(status : Round.RoundStatus) : Text {
    switch (status) {
      case (#Open) "OPEN";
      case (#AcceptEntries) "OPEN";
      case (#RoundClose) "CLOSED";
      case (#DrawWinners) "DRAWING";
      case (#DistributePrizes) "PAYING";
      case (#ArchiveRound) "ARCHIVING";
      case (#Completed) "COMPLETED";
    };
  };
};
