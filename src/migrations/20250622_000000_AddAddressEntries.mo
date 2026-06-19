import StableStorage "../storage/StableStorage";
import StableAddressEntryStore "../storage/StableAddressEntryStore";

module {
  public func migration(old : { storage : StableStorage.StoreWithProcessedDeposits }) : {
    storage : StableStorage.Store;
  } {
    {
      storage = {
        old.storage with
        addressEntries = StableAddressEntryStore.empty();
      };
    };
  };
};
