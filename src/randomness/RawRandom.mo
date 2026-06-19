import Random "mo:core/Random";
import Blob "mo:core/Blob";
import Nat "mo:core/Nat";
import Nat8 "mo:core/Nat8";
import Array "mo:core/Array";
import Result "mo:core/Result";

module {
  public type RandomProvider = {
    getRandomBytes : () -> async Blob;
  };

  public class IcpRandomProvider() {
    public func getRandomBytes() : async Blob {
      await Random.blob();
    };
  };

  public class DeterministicRandomProvider(seedBytes : [Nat8]) {
    var index : Nat = 0;

    public func getRandomBytes() : async Blob {
      let size = 32;
      let bytes = Array.tabulate<Nat8>(
        size,
        func(i) {
          let seedIndex = (index + i) % seedBytes.size();
          seedBytes[seedIndex];
        },
      );
      index += size;
      Blob.fromArray(bytes);
    };
  };

  public func bytesToNat(bytes : Blob) : Nat {
    let arr = Blob.toArray(bytes);
    var value : Nat = 0;
    for (byte in arr.vals()) {
      value := value * 256 + Nat8.toNat(byte);
    };
    value;
  };

  public func selectIndex(randomBytes : Blob, poolSize : Nat) : Nat {
    if (poolSize == 0) {
      return 0;
    };
    bytesToNat(randomBytes) % poolSize;
  };

  public type RandomResult = Result.Result<Blob, Text>;

  public func fetchRandom(provider : RandomProvider) : async RandomResult {
    try {
      #ok(await provider.getRandomBytes());
    } catch (_) {
      #err("randomness_unavailable");
    };
  };
};
