import Nat "mo:core/Nat";
import Text "mo:core/Text";

module {
  public type RecentEntryResponse = {
    accountHex : Text;
    amountE8s : Nat;
    // Deposit time in nanoseconds (ledger time when available, else processing time).
    timestampNanos : Int;
  };
};
