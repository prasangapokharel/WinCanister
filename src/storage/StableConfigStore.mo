import Config "../models/Config";

module {
  public type StableData = Config.Config;

  public type Store = {
    var config : Config.Config;
  };

  public func empty() : Store {
    { var config = Config.defaultConfig() };
  };

  public func toStable(store : Store) : StableData {
    store.config;
  };

  public func fromStable(data : StableData) : Store {
    { var config = data };
  };

  public func get(store : Store) : Config.Config {
    store.config;
  };

  public func set(store : Store, config : Config.Config) {
    store.config := config;
  };
};
