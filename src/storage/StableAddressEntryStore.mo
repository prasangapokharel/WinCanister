import Map "mo:core/Map";
import Nat "mo:core/Nat";
import Text "mo:core/Text";
import Order "mo:core/Order";
import Iter "mo:core/Iter";
import Array "mo:core/Array";
import AddressEntry "../models/AddressEntry";

module {
  public type EntryKey = (Nat, Text);

  public type StableData = {
    addressEntries : [((Nat, Text), AddressEntry.AddressEntry)];
  };

  public type Store = {
    var addressEntries : Map.Map<(Nat, Text), AddressEntry.AddressEntry>;
  };

  func compareKey(a : EntryKey, b : EntryKey) : Order.Order {
    switch (Nat.compare(a.0, b.0)) {
      case (#equal) Text.compare(a.1, b.1);
      case (other) other;
    };
  };

  public func empty() : Store {
    { var addressEntries = Map.empty<(Nat, Text), AddressEntry.AddressEntry>() };
  };

  public func toStable(store : Store) : StableData {
    { addressEntries = Iter.toArray(Map.entries(store.addressEntries)) };
  };

  public func fromStable(data : StableData) : Store {
    let store = empty();
    for ((key, entry) in data.addressEntries.vals()) {
      Map.add(store.addressEntries, compareKey, key, entry);
    };
    store;
  };

  public func findByRoundAndAccountHex(
    store : Store,
    roundId : Nat,
    accountHex : Text,
  ) : ?AddressEntry.AddressEntry {
    Map.get(store.addressEntries, compareKey, (roundId, accountHex));
  };

  public func save(store : Store, entry : AddressEntry.AddressEntry) {
    Map.add(store.addressEntries, compareKey, (entry.roundId, entry.accountHex), entry);
  };

  public func countByRound(store : Store, roundId : Nat) : Nat {
    var count = 0;
    for (((id, _), _) in Map.entries(store.addressEntries)) {
      if (id == roundId) { count += 1 };
    };
    count;
  };

  public func getAccountHexesByRound(store : Store, roundId : Nat) : [Text] {
    var results : [Text] = [];
    for (((id, accountHex), _) in Map.entries(store.addressEntries)) {
      if (id == roundId) {
        results := Array.concat(results, [accountHex]);
      };
    };
    results;
  };
};
