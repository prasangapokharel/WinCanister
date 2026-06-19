import Principal "mo:core/Principal";
import Nat "mo:core/Nat";
import Nat8 "mo:core/Nat8";
import Text "mo:core/Text";
import Blob "mo:core/Blob";
import Array "mo:core/Array";
import AccountIdentifier "AccountIdentifier";

module {
  public func syntheticPrincipalFromAccountHex(accountHex : Text) : Principal {
    switch (AccountIdentifier.hexToBlob(accountHex)) {
      case null Principal.anonymous();
      case (?accountBlob) {
        let bytes = Blob.toArray(accountBlob);
        let principalBytes = Array.tabulate<Nat8>(29, func(i) {
          if (i + 4 < bytes.size()) {
            bytes[i + 4];
          } else {
            0 : Nat8;
          };
        });
        Principal.fromBlob(Blob.fromArray(principalBytes));
      };
    };
  };

  public func payoutAccountHex(
    participant : Principal,
    addressHexes : [Text],
  ) : Text {
    for (accountHex in addressHexes.vals()) {
      if (Principal.equal(syntheticPrincipalFromAccountHex(accountHex), participant)) {
        return accountHex;
      };
    };
    AccountIdentifier.toHex(participant);
  };
};
