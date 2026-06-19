import Principal "mo:core/Principal";
import Nat "mo:core/Nat";
import Nat8 "mo:core/Nat8";
import Blob "mo:core/Blob";
import Array "mo:core/Array";

module {
  func principalFromSeed(seed : Nat) : Principal {
    let bytes = Array.tabulate<Nat8>(29, func(i) { Nat8.fromNat((seed + i) % 256) });
    Principal.fromBlob(Blob.fromArray(bytes));
  };

  public func participant1() : Principal { principalFromSeed(1) };
  public func participant2() : Principal { principalFromSeed(2) };
  public func participant3() : Principal { principalFromSeed(3) };
  public func participant4() : Principal { principalFromSeed(4) };
  public func canisterOwner() : Principal { principalFromSeed(255) };
};
