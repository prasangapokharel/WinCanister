import Nat "mo:core/Nat";
import Statistics "../models/Statistics";

module {
  public type PublicStatisticsResponse = {
    totalRounds : Nat;
    totalParticipants : Nat;
    totalPoolCollected : Nat;
    totalPaidOut : Nat;
    totalTreasuryRevenue : Nat;
  };

  public func fromStatistics(stats : Statistics.Statistics) : PublicStatisticsResponse {
    {
      totalRounds = stats.totalRounds;
      totalParticipants = stats.totalEntries;
      totalPoolCollected = stats.totalIcpCollected;
      totalPaidOut = stats.totalPrizesPaid;
      totalTreasuryRevenue = stats.totalTreasuryTransferred;
    };
  };
};
