import Nat "mo:core/Nat";

module {
  public type Treasury = {
    totalAccrued : Nat;
    totalTransferred : Nat;
  };

  public func empty() : Treasury {
    { totalAccrued = 0; totalTransferred = 0 };
  };
};
