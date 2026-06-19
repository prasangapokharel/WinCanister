import Array "mo:core/Array";
import Nat64 "mo:core/Nat64";
import Principal "mo:core/Principal";
import Result "mo:core/Result";
import IndexPort "IndexPort";

module {
  public class Client() {
    var transfers : [IndexPort.IncomingTransfer] = [];

    public func addTransfer(transfer : IndexPort.IncomingTransfer) {
      transfers := Array.concat(transfers, [transfer]);
    };

    public func getIncomingTransfers(
      _recipient : Principal,
      _maxResults : Nat64,
    ) : async Result.Result<[IndexPort.IncomingTransfer], Text> {
      #ok(transfers);
    };
  };
};
