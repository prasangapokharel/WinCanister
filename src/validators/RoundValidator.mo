import Round "../models/Round";
import TimeUtil "../utils/TimeUtil";
import AppConfig "../config/AppConfig";

module {
  public func validateRoundExists(round : ?Round.Round) : ?Text {
    switch (round) {
      case null ?"round_not_found";
      case (?_) null;
    };
  };

  public func validateRoundExpired(round : Round.Round) : Bool {
    TimeUtil.hasElapsed(round.startTime, AppConfig.ROUND_DURATION_NS);
  };

  public func validateCanClose(round : Round.Round) : ?Text {
    if (not Round.isAcceptingEntries(round)) {
      ?"round_not_open";
    } else if (not validateRoundExpired(round)) {
      ?"round_not_expired";
    } else {
      null;
    };
  };

  public func validateCanDraw(round : Round.Round) : ?Text {
    switch (round.status) {
      case (#RoundClose) null;
      case (_) ?"round_not_ready_for_draw";
    };
  };

  public func validateCanDistribute(round : Round.Round) : ?Text {
    switch (round.status) {
      case (#DrawWinners) null;
      case (_) ?"round_not_ready_for_payout";
    };
  };
};
