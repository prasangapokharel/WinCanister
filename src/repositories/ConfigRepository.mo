import StableConfigStore "../storage/StableConfigStore";
import Config "../models/Config";

module {
  public class Repository(store : StableConfigStore.Store) {
    public func get() : Config.Config {
      StableConfigStore.get(store);
    };

    public func set(config : Config.Config) {
      StableConfigStore.set(store, config);
    };
  };
};
