import Map "mo:core/Map";
import Nat "mo:core/Nat";
import Order "mo:core/Order";
import Iter "mo:core/Iter";
import Array "mo:core/Array";
import PayoutRecord "../models/PayoutRecord";

module {
  public type PayoutKey = (Nat, Nat);

  public type StableData = {
    payouts : [((Nat, Nat), PayoutRecord.PayoutRecord)];
    nextPayoutId : Nat;
  };

  public type Store = {
    var payouts : Map.Map<(Nat, Nat), PayoutRecord.PayoutRecord>;
    var nextPayoutId : Nat;
  };

  func compareKey(a : PayoutKey, b : PayoutKey) : Order.Order {
    switch (Nat.compare(a.0, b.0)) {
      case (#equal) Nat.compare(a.1, b.1);
      case (other) other;
    };
  };

  public func empty() : Store {
    {
      var payouts = Map.empty<(Nat, Nat), PayoutRecord.PayoutRecord>();
      var nextPayoutId = 0;
    };
  };

  public func toStable(store : Store) : StableData {
    {
      payouts = Iter.toArray(Map.entries(store.payouts));
      nextPayoutId = store.nextPayoutId;
    };
  };

  public func fromStable(data : StableData) : Store {
    let store = empty();
    store.nextPayoutId := data.nextPayoutId;
    for ((key, payout) in data.payouts.vals()) {
      Map.add(store.payouts, compareKey, key, payout);
    };
    store;
  };

  public func save(store : Store, payout : PayoutRecord.PayoutRecord) : Nat {
    let id = store.nextPayoutId;
    store.nextPayoutId += 1;
    Map.add(store.payouts, compareKey, (payout.roundId, id), payout);
    id;
  };

  public func getByRound(store : Store, roundId : Nat) : [PayoutRecord.PayoutRecord] {
    var results : [PayoutRecord.PayoutRecord] = [];
    for (((id, _), payout) in Map.entries(store.payouts)) {
      if (id == roundId) {
        results := Array.concat(results, [payout]);
      };
    };
    results;
  };
};
