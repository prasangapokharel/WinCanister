import Nat "mo:core/Nat";
import AppConfig "../config/AppConfig";

module {
  public func calculateTreasuryFee(totalCollected : Nat) : Nat {
    totalCollected * AppConfig.TREASURY_BASIS_POINTS / AppConfig.BASIS_POINTS_DENOMINATOR;
  };

  public func calculatePrizePool(totalCollected : Nat) : Nat {
    totalCollected - calculateTreasuryFee(totalCollected);
  };

  public func calculatePrizeAmount(prizePool : Nat, basisPoints : Nat) : Nat {
    prizePool * basisPoints / AppConfig.BASIS_POINTS_DENOMINATOR;
  };

  public func minNat(a : Nat, b : Nat) : Nat {
    if (a < b) { a } else { b };
  };
};
