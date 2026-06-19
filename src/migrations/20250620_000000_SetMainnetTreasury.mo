import StableStorage "../storage/StableStorage";
import StableConfigStore "../storage/StableConfigStore";
import Config "../models/Config";

module {
  public func migration(old : { storage : StableStorage.StorePreDeposits }) : {
    storage : StableStorage.StorePreDeposits;
  } {
    StableConfigStore.set(old.storage.config, Config.defaultConfig());
    { storage = old.storage };
  };
};
