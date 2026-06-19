import Nat "mo:core/Nat";
import AppConfig "../config/AppConfig";
import Helpers "../utils/Helpers";

module {
  public type PrizeBreakdown = {
    firstPlace : Nat;
    secondPlace : Nat;
    thirdPlace : Nat;
    treasuryFromUnclaimed : Nat;
  };

  public func calculatePrizeBreakdown(prizePool : Nat, winnerCount : Nat) : PrizeBreakdown {
    let firstShare = Helpers.calculatePrizeAmount(prizePool, AppConfig.FIRST_PLACE_BPS);
    let secondShare = Helpers.calculatePrizeAmount(prizePool, AppConfig.SECOND_PLACE_BPS);
    let thirdShare = Helpers.calculatePrizeAmount(prizePool, AppConfig.THIRD_PLACE_BPS);

    switch (winnerCount) {
      case (0) {
        {
          firstPlace = 0;
          secondPlace = 0;
          thirdPlace = 0;
          treasuryFromUnclaimed = prizePool;
        };
      };
      case (1) {
        {
          firstPlace = prizePool;
          secondPlace = 0;
          thirdPlace = 0;
          treasuryFromUnclaimed = 0;
        };
      };
      case (2) {
        {
          firstPlace = firstShare;
          secondPlace = secondShare;
          thirdPlace = 0;
          treasuryFromUnclaimed = thirdShare;
        };
      };
      case (_) {
        {
          firstPlace = firstShare;
          secondPlace = secondShare;
          thirdPlace = thirdShare;
          treasuryFromUnclaimed = 0;
        };
      };
    };
  };

  public func getPrizeForPosition(breakdown : PrizeBreakdown, position : Nat) : Nat {
    switch (position) {
      case (1) breakdown.firstPlace;
      case (2) breakdown.secondPlace;
      case (3) breakdown.thirdPlace;
      case (_) 0;
    };
  };
};
