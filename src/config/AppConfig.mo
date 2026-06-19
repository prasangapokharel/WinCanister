import Nat "mo:core/Nat";

module {
  public let MIN_ENTRY_AMOUNT : Nat = 100_000_000;
  public let LEDGER_TRANSFER_FEE : Nat = 10_000;
  public let ROUND_DURATION_NS : Nat = 86_400_000_000_000;
  public let TREASURY_BASIS_POINTS : Nat = 100;
  public let BASIS_POINTS_DENOMINATOR : Nat = 10_000;
  public let FIRST_PLACE_BPS : Nat = 6_000;
  public let SECOND_PLACE_BPS : Nat = 2_500;
  public let THIRD_PLACE_BPS : Nat = 1_500;
  public let MAX_WINNERS : Nat = 3;
  public let ROUND_CHECK_INTERVAL_NS : Nat = 60_000_000_000;
};
