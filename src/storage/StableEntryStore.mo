import Map "mo:core/Map";
import Nat "mo:core/Nat";
import Principal "mo:core/Principal";
import Order "mo:core/Order";
import Iter "mo:core/Iter";
import Array "mo:core/Array";
import Entry "../models/Entry";

module {
  public type EntryKey = (Nat, Principal);

  public type StableData = {
    entries : [((Nat, Principal), Entry.Entry)];
  };

  public type Store = {
    var entries : Map.Map<(Nat, Principal), Entry.Entry>;
  };

  func compareKey(a : EntryKey, b : EntryKey) : Order.Order {
    switch (Nat.compare(a.0, b.0)) {
      case (#equal) Principal.compare(a.1, b.1);
      case (other) other;
    };
  };

  public func empty() : Store {
    { var entries = Map.empty<(Nat, Principal), Entry.Entry>() };
  };

  public func toStable(store : Store) : StableData {
    { entries = Iter.toArray(Map.entries(store.entries)) };
  };

  public func fromStable(data : StableData) : Store {
    let store = empty();
    for ((key, entry) in data.entries.vals()) {
      Map.add(store.entries, compareKey, key, entry);
    };
    store;
  };

  public func findByRoundAndParticipant(
    store : Store,
    roundId : Nat,
    participant : Principal,
  ) : ?Entry.Entry {
    Map.get(store.entries, compareKey, (roundId, participant));
  };

  public func save(store : Store, entry : Entry.Entry) {
    Map.add(store.entries, compareKey, (entry.roundId, entry.participant), entry);
  };

  public func countByRound(store : Store, roundId : Nat) : Nat {
    var count = 0;
    for (((id, _), _) in Map.entries(store.entries)) {
      if (id == roundId) { count += 1 };
    };
    count;
  };

  public func getByRound(store : Store, roundId : Nat) : [Entry.Entry] {
    var results : [Entry.Entry] = [];
    for (((id, _), entry) in Map.entries(store.entries)) {
      if (id == roundId) {
        results := Array.concat(results, [entry]);
      };
    };
    results;
  };

  public func getParticipantsByRound(store : Store, roundId : Nat) : [Principal] {
    let entries = getByRound(store, roundId);
    Array.map<Entry.Entry, Principal>(entries, func(e) { e.participant });
  };
};
