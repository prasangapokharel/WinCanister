import Principal "mo:core/Principal";
import Text "mo:core/Text";

module {
  public type PayoutEntryResponse = {
    accountHex : Text;
    amount : Nat;
    txId : Nat;
    paid : Bool;
  };

  public type PayoutDetailsResponse = {
    roundId : Nat;
    winner1 : ?PayoutEntryResponse;
    winner2 : ?PayoutEntryResponse;
    winner3 : ?PayoutEntryResponse;
    treasury : ?PayoutEntryResponse;
  };
};
