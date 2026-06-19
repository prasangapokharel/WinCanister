import Principal "mo:core/Principal";
import Nat "mo:core/Nat";
import Entry "../models/Entry";
import StableEntryStore "../storage/StableEntryStore";

module {
  public class Repository(store : StableEntryStore.Store) {
    public func findByRoundAndParticipant(roundId : Nat, participant : Principal) : ?Entry.Entry {
      StableEntryStore.findByRoundAndParticipant(store, roundId, participant);
    };

    public func save(entry : Entry.Entry) {
      StableEntryStore.save(store, entry);
    };

    public func countByRound(roundId : Nat) : Nat {
      StableEntryStore.countByRound(store, roundId);
    };

    public func getByRound(roundId : Nat) : [Entry.Entry] {
      StableEntryStore.getByRound(store, roundId);
    };

    public func getParticipantsByRound(roundId : Nat) : [Principal] {
      StableEntryStore.getParticipantsByRound(store, roundId);
    };
  };
};
