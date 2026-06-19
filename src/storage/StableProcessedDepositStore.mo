import Map "mo:core/Map";
import Nat "mo:core/Nat";
import Nat64 "mo:core/Nat64";
import Order "mo:core/Order";
import Iter "mo:core/Iter";

module {
  public type StableData = {
    processedTxIds : [Nat64];
  };

  public type Store = {
    var processedTxIds : Map.Map<Nat64, ()>;
  };

  public func empty() : Store {
    { var processedTxIds = Map.empty<Nat64, ()>() };
  };

  public func toStable(store : Store) : StableData {
    {
      processedTxIds = Iter.toArray(Map.keys(store.processedTxIds));
    };
  };

  public func fromStable(data : StableData) : Store {
    let store = empty();
    for (txId in data.processedTxIds.vals()) {
      Map.add(store.processedTxIds, Nat64.compare, txId, ());
    };
    store;
  };

  public func isProcessed(store : Store, txId : Nat64) : Bool {
    Map.containsKey(store.processedTxIds, Nat64.compare, txId);
  };

  public func markProcessed(store : Store, txId : Nat64) {
    Map.add(store.processedTxIds, Nat64.compare, txId, ());
  };
};
