import Map "mo:core/Map";
import Nat "mo:core/Nat";
import Iter "mo:core/Iter";
import Array "mo:core/Array";
import Round "../models/Round";

module {
  public type StableData = {
    currentRoundId : Nat;
    rounds : [(Nat, Round.Round)];
    roundHistory : [Nat];
  };

  public type Store = {
    var currentRoundId : Nat;
    var rounds : Map.Map<Nat, Round.Round>;
    var roundHistory : [Nat];
  };

  public func empty() : Store {
    {
      var currentRoundId = 0;
      var rounds = Map.empty<Nat, Round.Round>();
      var roundHistory : [Nat] = [];
    };
  };

  public func toStable(store : Store) : StableData {
    {
      currentRoundId = store.currentRoundId;
      rounds = Iter.toArray(Map.entries(store.rounds));
      roundHistory = store.roundHistory;
    };
  };

  public func fromStable(data : StableData) : Store {
    let store = empty();
    store.currentRoundId := data.currentRoundId;
    for ((id, round) in data.rounds.vals()) {
      Map.add(store.rounds, Nat.compare, id, round);
    };
    store.roundHistory := data.roundHistory;
    store;
  };

  public func getCurrentRoundId(store : Store) : Nat {
    store.currentRoundId;
  };

  public func setCurrentRoundId(store : Store, id : Nat) {
    store.currentRoundId := id;
  };

  public func findById(store : Store, id : Nat) : ?Round.Round {
    Map.get(store.rounds, Nat.compare, id);
  };

  public func save(store : Store, round : Round.Round) {
    Map.add(store.rounds, Nat.compare, round.id, round);
  };

  public func addToHistory(store : Store, roundId : Nat) {
    store.roundHistory := Array.concat(store.roundHistory, [roundId]);
  };

  public func getHistory(store : Store) : [Nat] {
    store.roundHistory;
  };

  public func getAllRounds(store : Store) : [Round.Round] {
    Iter.toArray(Map.values(store.rounds));
  };
};
