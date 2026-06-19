import StableStorage "../storage/StableStorage";
import StableProcessedDepositStore "../storage/StableProcessedDepositStore";

module {
  public func migration(old : { storage : StableStorage.StorePreDeposits }) : {
    storage : StableStorage.StoreWithProcessedDeposits;
  } {
    {
      storage = {
        old.storage with
        processedDeposits = StableProcessedDepositStore.empty();
      };
    };
  };
};
