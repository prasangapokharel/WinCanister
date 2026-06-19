import Nat "mo:core/Nat";

module {
  public type Statistics = {
    totalRounds : Nat;
    totalEntries : Nat;
    totalWinners : Nat;
    totalIcpCollected : Nat;
    totalPrizesPaid : Nat;
    totalTreasuryTransferred : Nat;
  };

  public func empty() : Statistics {
    {
      totalRounds = 0;
      totalEntries = 0;
      totalWinners = 0;
      totalIcpCollected = 0;
      totalPrizesPaid = 0;
      totalTreasuryTransferred = 0;
    };
  };
};
