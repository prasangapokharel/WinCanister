import Round "../models/Round";

module {
  public func guardRoundActive(round : ?Round.Round) : ?Text {
    switch (round) {
      case null ?"no_active_round";
      case (?r) {
        if (Round.isActive(r)) {
          null;
        } else {
          ?"round_not_active";
        };
      };
    };
  };
};
