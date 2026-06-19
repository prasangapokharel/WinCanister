import StableWinnerStore "../storage/StableWinnerStore";
import Winner "../models/Winner";
import Nat "mo:core/Nat";

module {
  public class Repository(store : StableWinnerStore.Store) {
    public func save(winner : Winner.Winner) {
      StableWinnerStore.save(store, winner);
    };

    public func getByRound(roundId : Nat) : [Winner.Winner] {
      StableWinnerStore.getByRound(store, roundId);
    };

    public func findByRoundAndPosition(roundId : Nat, position : Nat) : ?Winner.Winner {
      StableWinnerStore.findByRoundAndPosition(store, roundId, position);
    };
  };
};
