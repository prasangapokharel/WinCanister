import Nat "mo:core/Nat";
import Text "mo:core/Text";
import AddressEntry "../models/AddressEntry";
import StableAddressEntryStore "../storage/StableAddressEntryStore";

module {
  public class Repository(store : StableAddressEntryStore.Store) {
    public func findByRoundAndAccountHex(roundId : Nat, accountHex : Text) : ?AddressEntry.AddressEntry {
      StableAddressEntryStore.findByRoundAndAccountHex(store, roundId, accountHex);
    };

    public func save(entry : AddressEntry.AddressEntry) {
      StableAddressEntryStore.save(store, entry);
    };

    public func countByRound(roundId : Nat) : Nat {
      StableAddressEntryStore.countByRound(store, roundId);
    };

    public func getAccountHexesByRound(roundId : Nat) : [Text] {
      StableAddressEntryStore.getAccountHexesByRound(store, roundId);
    };

    public func getEntriesByRound(roundId : Nat) : [AddressEntry.AddressEntry] {
      StableAddressEntryStore.getEntriesByRound(store, roundId);
    };
  };
};
