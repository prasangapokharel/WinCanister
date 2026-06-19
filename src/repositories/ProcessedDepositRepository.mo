import StableProcessedDepositStore "../storage/StableProcessedDepositStore";
import Nat64 "mo:core/Nat64";

module {
  public class Repository(store : StableProcessedDepositStore.Store) {
    public func isProcessed(txId : Nat64) : Bool {
      StableProcessedDepositStore.isProcessed(store, txId);
    };

    public func markProcessed(txId : Nat64) {
      StableProcessedDepositStore.markProcessed(store, txId);
    };
  };
};
