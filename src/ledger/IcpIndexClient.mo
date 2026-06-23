import IcpIndex "canister:icp_index";
import Array "mo:core/Array";
import Nat "mo:core/Nat";
import Nat64 "mo:core/Nat64";
import Principal "mo:core/Principal";
import Result "mo:core/Result";
import IndexPort "IndexPort";
import AccountIdentifier "../utils/AccountIdentifier";

module {
  public class Client() {
    public func getIncomingTransfers(
      recipient : Principal,
      maxResults : Nat64,
    ) : async Result.Result<[IndexPort.IncomingTransfer], Text> {
      let accountHex = AccountIdentifier.toHex(recipient);
      let args : IcpIndex.GetAccountIdentifierTransactionsArgs = {
        account_identifier = accountHex;
        max_results = maxResults;
        start = null;
      };
      switch (await IcpIndex.get_account_identifier_transactions(args)) {
        case (#Err(err)) #err(err.message);
        case (#Ok(response)) {
          var transfers : [IndexPort.IncomingTransfer] = [];
          for (item in response.transactions.vals()) {
            switch (item.transaction.operation) {
              case (#Transfer(details)) {
                if (details.to == accountHex) {
                  let timestampNanos = switch (item.transaction.created_at_time) {
                    case (?ts) ?Nat64.toNat(ts.timestamp_nanos);
                    case null null;
                  };
                  transfers := Array.concat(transfers, [{
                    txId = item.id;
                    fromAccountHex = details.from;
                    amountE8s = Nat64.toNat(details.amount.e8s);
                    timestampNanos = timestampNanos;
                  }]);
                };
              };
              case (_) {};
            };
          };
          #ok(transfers);
        };
      };
    };
  };
};
