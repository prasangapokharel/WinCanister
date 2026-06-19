import StableStorage "../storage/StableStorage";

module {
  public func migration(_ : {}) : {
    storage : StableStorage.StorePreDeposits;
    isInitialized : Bool;
  } {
    {
      storage = StableStorage.emptyPreDeposits();
      isInitialized = false;
    };
  };
};
