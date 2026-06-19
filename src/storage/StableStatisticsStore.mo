import Statistics "../models/Statistics";

module {
  public type StableData = Statistics.Statistics;

  public type Store = {
    var statistics : Statistics.Statistics;
  };

  public func empty() : Store {
    { var statistics = Statistics.empty() };
  };

  public func toStable(store : Store) : StableData {
    store.statistics;
  };

  public func fromStable(data : StableData) : Store {
    { var statistics = data };
  };

  public func get(store : Store) : Statistics.Statistics {
    store.statistics;
  };

  public func set(store : Store, statistics : Statistics.Statistics) {
    store.statistics := statistics;
  };
};
