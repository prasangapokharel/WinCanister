import Principal "mo:core/Principal";
import Blob "mo:core/Blob";

module {
  public type Account = {
    owner : Principal;
    subaccount : ?Blob;
  };

  public func defaultAccount(owner : Principal) : Account {
    { owner = owner; subaccount = null };
  };
};
