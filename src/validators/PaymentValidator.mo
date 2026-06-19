import Nat "mo:core/Nat";
import AppConfig "../config/AppConfig";

module {
  public func validateTransferAmount(amount : Nat) : ?Text {
    if (amount < AppConfig.MIN_ENTRY_AMOUNT) {
      ?"transfer_amount_below_minimum";
    } else {
      null;
    };
  };

  public func validatePayoutAmount(amount : Nat) : ?Text {
    if (amount == 0) {
      ?"payout_amount_zero";
    } else {
      null;
    };
  };

  public func validateSufficientPool(prizePool : Nat, payoutTotal : Nat) : ?Text {
    if (payoutTotal > prizePool) {
      ?"payout_exceeds_prize_pool";
    } else {
      null;
    };
  };
};
