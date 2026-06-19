import StablePayoutStore "../storage/StablePayoutStore";
import PayoutRecord "../models/PayoutRecord";
import Nat "mo:core/Nat";

module {
  public class Repository(store : StablePayoutStore.Store) {
    public func save(payout : PayoutRecord.PayoutRecord) : Nat {
      StablePayoutStore.save(store, payout);
    };

    public func getByRound(roundId : Nat) : [PayoutRecord.PayoutRecord] {
      StablePayoutStore.getByRound(store, roundId);
    };
  };
};
