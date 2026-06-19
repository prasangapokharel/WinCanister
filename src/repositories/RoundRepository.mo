import StableRoundStore "../storage/StableRoundStore";
import Round "../models/Round";
import Nat "mo:core/Nat";

module {
  public class Repository(store : StableRoundStore.Store) {
    public func findById(id : Nat) : ?Round.Round {
      StableRoundStore.findById(store, id);
    };

    public func save(round : Round.Round) {
      StableRoundStore.save(store, round);
    };

    public func getCurrentRoundId() : Nat {
      StableRoundStore.getCurrentRoundId(store);
    };

    public func setCurrentRoundId(id : Nat) {
      StableRoundStore.setCurrentRoundId(store, id);
    };

    public func addToHistory(roundId : Nat) {
      StableRoundStore.addToHistory(store, roundId);
    };

    public func getHistory() : [Nat] {
      StableRoundStore.getHistory(store);
    };

    public func getAllRounds() : [Round.Round] {
      StableRoundStore.getAllRounds(store);
    };
  };
};
