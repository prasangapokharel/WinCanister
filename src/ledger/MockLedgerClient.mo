import Map "mo:core/Map";
import Principal "mo:core/Principal";
import Nat "mo:core/Nat";
import Text "mo:core/Text";
import Blob "mo:core/Blob";
import Result "mo:core/Result";
import AppConfig "../config/AppConfig";
import AccountIdentifier "../utils/AccountIdentifier";

module {
  public class Client() {
    var balances = Map.empty<Principal, Nat>();
    var accountBalances = Map.empty<Text, Nat>();
    var nextBlockIndex : Nat = 0;
    var shouldFailTransfer : Bool = false;
    var shouldFailTransferFrom : Bool = false;
    var canisterOwner : ?Principal = null;

    public func setCanisterOwner(owner : Principal) {
      canisterOwner := ?owner;
    };

    public func setBalance(owner : Principal, amount : Nat) {
      Map.add(balances, Principal.compare, owner, amount);
    };

    public func setTransferFailure(shouldFail : Bool) {
      shouldFailTransfer := shouldFail;
    };

    public func setTransferFromFailure(shouldFail : Bool) {
      shouldFailTransferFrom := shouldFail;
    };

    public func transferFrom(
      from : Principal,
      to : Principal,
      amount : Nat,
    ) : async Result.Result<Nat, Text> {
      if (shouldFailTransferFrom) {
        return #err("mock_transfer_from_failed");
      };
      let fromBalance = getBalance(from);
      let totalCost = amount + AppConfig.LEDGER_TRANSFER_FEE;
      if (fromBalance < totalCost) {
        return #err("insufficient_funds: balance " # Nat.toText(fromBalance));
      };
      setBalanceInternal(from, fromBalance - totalCost);
      setBalanceInternal(to, getBalance(to) + amount);
      let blockIndex = nextBlockIndex;
      nextBlockIndex += 1;
      #ok(blockIndex);
    };

    public func transfer(
      to : Principal,
      amount : Nat,
      fromSubaccount : ?Blob,
    ) : async Result.Result<Nat, Text> {
      ignore fromSubaccount;
      if (shouldFailTransfer) {
        return #err("mock_transfer_failed");
      };
      switch (canisterOwner) {
        case (?owner) {
          let ownerBalance = getBalance(owner);
          let totalCost = amount + AppConfig.LEDGER_TRANSFER_FEE;
          if (ownerBalance < totalCost) {
            return #err("insufficient_funds: balance " # Nat.toText(ownerBalance));
          };
          setBalanceInternal(owner, ownerBalance - totalCost);
        };
        case null {};
      };
      setBalanceInternal(to, getBalance(to) + amount);
      let blockIndex = nextBlockIndex;
      nextBlockIndex += 1;
      #ok(blockIndex);
    };

    public func setAccountBalance(accountHex : Text, amount : Nat) {
      Map.add(accountBalances, Text.compare, accountHex, amount);
    };

    public func transferToAccountHex(
      accountHex : Text,
      amount : Nat,
      fromSubaccount : ?Blob,
    ) : async Result.Result<Nat, Text> {
      ignore fromSubaccount;
      if (shouldFailTransfer) {
        return #err("mock_transfer_failed");
      };
      switch (canisterOwner) {
        case (?owner) {
          let ownerBalance = getBalance(owner);
          let totalCost = amount + AppConfig.LEDGER_TRANSFER_FEE;
          if (ownerBalance < totalCost) {
            return #err("insufficient_funds: balance " # Nat.toText(ownerBalance));
          };
          setBalanceInternal(owner, ownerBalance - totalCost);
        };
        case null {};
      };
      setAccountBalance(accountHex, getAccountBalance(accountHex) + amount);
      let blockIndex = nextBlockIndex;
      nextBlockIndex += 1;
      #ok(blockIndex);
    };

    public func balanceOf(account : Principal) : async Nat {
      getBalance(account);
    };

    func getBalance(owner : Principal) : Nat {
      switch (Map.get(balances, Principal.compare, owner)) {
        case (?balance) balance;
        case null 0;
      };
    };

    func getAccountBalance(accountHex : Text) : Nat {
      switch (Map.get(accountBalances, Text.compare, accountHex)) {
        case (?balance) balance;
        case null 0;
      };
    };

    func setBalanceInternal(owner : Principal, amount : Nat) {
      Map.add(balances, Principal.compare, owner, amount);
    };
  };
};
