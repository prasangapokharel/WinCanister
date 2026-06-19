import Nat64 "mo:core/Nat64";
import Principal "mo:core/Principal";
import Nat "mo:core/Nat";
import Text "mo:core/Text";

module {
  public type AddressEntry = {
    roundId : Nat;
    accountHex : Text;
    amount : Nat;
    timestamp : Int;
    txId : Nat64;
  };

  public func newAddressEntry(
    roundId : Nat,
    accountHex : Text,
    amount : Nat,
    timestamp : Int,
    txId : Nat64,
  ) : AddressEntry {
    {
      roundId = roundId;
      accountHex = accountHex;
      amount = amount;
      timestamp = timestamp;
      txId = txId;
    };
  };
};
