import StableTreasuryStore "../storage/StableTreasuryStore";
import Treasury "../models/Treasury";

module {
  public class Repository(store : StableTreasuryStore.Store) {
    public func get() : Treasury.Treasury {
      StableTreasuryStore.get(store);
    };

    public func set(treasury : Treasury.Treasury) {
      StableTreasuryStore.set(store, treasury);
    };
  };
};
