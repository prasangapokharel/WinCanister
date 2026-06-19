import Nat "mo:core/Nat";
import Nat64 "mo:core/Nat64";
import Text "mo:core/Text";
import Principal "mo:core/Principal";
import Result "mo:core/Result";

module {
  public type IncomingTransfer = {
    txId : Nat64;
    fromAccountHex : Text;
    amountE8s : Nat;
  };

  public type Port = {
    getIncomingTransfers : (
      Principal,
      Nat64,
    ) -> async Result.Result<[IncomingTransfer], Text>;
  };
};
