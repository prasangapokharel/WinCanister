import StableStatisticsStore "../storage/StableStatisticsStore";
import Statistics "../models/Statistics";

module {
  public class Repository(store : StableStatisticsStore.Store) {
    public func get() : Statistics.Statistics {
      StableStatisticsStore.get(store);
    };

    public func set(statistics : Statistics.Statistics) {
      StableStatisticsStore.set(store, statistics);
    };
  };
};
