import Principal "mo:core/Principal";
import Nat "mo:core/Nat";
import AppConfig "../config/AppConfig";
import Round "../models/Round";

module {
  public func validateCaller(caller : Principal) : ?Text {
    if (Principal.isAnonymous(caller)) {
      ?"anonymous_caller_not_allowed";
    } else {
      null;
    };
  };

  public func validateAmount(amount : Nat) : ?Text {
    if (amount < AppConfig.MIN_ENTRY_AMOUNT) {
      ?"amount_below_minimum";
    } else {
      null;
    };
  };

  public func validateNotDuplicate(alreadyEntered : Bool) : ?Text {
    if (alreadyEntered) {
      ?"duplicate_entry";
    } else {
      null;
    };
  };

  public func validateRoundAcceptingEntries(round : Round.Round) : ?Text {
    if (not Round.isAcceptingEntries(round)) {
      ?"round_not_accepting_entries";
    } else {
      null;
    };
  };
};
