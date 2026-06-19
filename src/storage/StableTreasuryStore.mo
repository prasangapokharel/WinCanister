import Treasury "../models/Treasury";

module {
  public type StableData = Treasury.Treasury;

  public type Store = {
    var treasury : Treasury.Treasury;
  };

  public func empty() : Store {
    { var treasury = Treasury.empty() };
  };

  public func toStable(store : Store) : StableData {
    store.treasury;
  };

  public func fromStable(data : StableData) : Store {
    { var treasury = data };
  };

  public func get(store : Store) : Treasury.Treasury {
    store.treasury;
  };

  public func set(store : Store, treasury : Treasury.Treasury) {
    store.treasury := treasury;
  };
};
