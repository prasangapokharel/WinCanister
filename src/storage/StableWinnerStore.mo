import Map "mo:core/Map";
import Nat "mo:core/Nat";
import Principal "mo:core/Principal";
import Order "mo:core/Order";
import Iter "mo:core/Iter";
import Array "mo:core/Array";
import Winner "../models/Winner";

module {
  public type WinnerKey = (Nat, Nat);

  public type StableData = {
    winners : [((Nat, Nat), Winner.Winner)];
  };

  public type Store = {
    var winners : Map.Map<(Nat, Nat), Winner.Winner>;
  };

  func compareKey(a : WinnerKey, b : WinnerKey) : Order.Order {
    switch (Nat.compare(a.0, b.0)) {
      case (#equal) Nat.compare(a.1, b.1);
      case (other) other;
    };
  };

  public func empty() : Store {
    { var winners = Map.empty<(Nat, Nat), Winner.Winner>() };
  };

  public func toStable(store : Store) : StableData {
    { winners = Iter.toArray(Map.entries(store.winners)) };
  };

  public func fromStable(data : StableData) : Store {
    let store = empty();
    for ((key, winner) in data.winners.vals()) {
      Map.add(store.winners, compareKey, key, winner);
    };
    store;
  };

  public func save(store : Store, winner : Winner.Winner) {
    Map.add(store.winners, compareKey, (winner.roundId, winner.position), winner);
  };

  public func getByRound(store : Store, roundId : Nat) : [Winner.Winner] {
    var results : [Winner.Winner] = [];
    for (((id, _), winner) in Map.entries(store.winners)) {
      if (id == roundId) {
        results := Array.concat(results, [winner]);
      };
    };
    results;
  };

  public func findByRoundAndPosition(
    store : Store,
    roundId : Nat,
    position : Nat,
  ) : ?Winner.Winner {
    Map.get(store.winners, compareKey, (roundId, position));
  };
};
