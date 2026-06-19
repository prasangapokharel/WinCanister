import Principal "mo:core/Principal";
import Nat "mo:core/Nat";
import Nat64 "mo:core/Nat64";
import Int "mo:core/Int";
import Time "mo:core/Time";
import Blob "mo:core/Blob";
import Text "mo:core/Text";
import Result "mo:core/Result";
import Icrc1Ledger "canister:icrc1_ledger";
import Account "Account";
import AppConfig "../config/AppConfig";
import AccountIdentifier "../utils/AccountIdentifier";

module {
  public class Client() {
    public func transferFrom(
      from : Principal,
      to : Principal,
      amount : Nat,
    ) : async Result.Result<Nat, Text> {
      let now = Nat64.fromNat(Int.abs(Time.now()));
      let args : Icrc1Ledger.TransferFromArgs = {
        spender_subaccount = null;
        from = Account.defaultAccount(from);
        to = Account.defaultAccount(to);
        amount = amount;
        fee = ?AppConfig.LEDGER_TRANSFER_FEE;
        memo = null;
        created_at_time = ?now;
      };
      switch (await Icrc1Ledger.icrc2_transfer_from(args)) {
        case (#Ok(blockIndex)) #ok(blockIndex);
        case (#Err(err)) #err(formatTransferFromError(err));
      };
    };

    public func transfer(
      to : Principal,
      amount : Nat,
      fromSubaccount : ?Blob,
    ) : async Result.Result<Nat, Text> {
      let now = Nat64.fromNat(Int.abs(Time.now()));
      let args : Icrc1Ledger.TransferArg = {
        from_subaccount = fromSubaccount;
        to = Account.defaultAccount(to);
        amount = amount;
        fee = ?AppConfig.LEDGER_TRANSFER_FEE;
        memo = null;
        created_at_time = ?now;
      };
      switch (await Icrc1Ledger.icrc1_transfer(args)) {
        case (#Ok(blockIndex)) #ok(blockIndex);
        case (#Err(err)) #err(formatIcrc1TransferError(err));
      };
    };

    public func transferToAccountHex(
      accountHex : Text,
      amount : Nat,
      fromSubaccount : ?Blob,
    ) : async Result.Result<Nat, Text> {
      switch (AccountIdentifier.hexToBlob(accountHex)) {
        case null return #err("invalid_account_hex");
        case (?accountId) {
          let now = Nat64.fromNat(Int.abs(Time.now()));
          let args : Icrc1Ledger.TransferArgs = {
            memo = 0;
            amount = { e8s = Nat64.fromNat(amount) };
            fee = { e8s = Nat64.fromNat(AppConfig.LEDGER_TRANSFER_FEE) };
            from_subaccount = fromSubaccount;
            to = accountId;
            created_at_time = ?{ timestamp_nanos = now };
          };
          switch (await Icrc1Ledger.transfer(args)) {
            case (#Ok(blockIndex)) #ok(Nat64.toNat(blockIndex));
            case (#Err(err)) #err(formatLegacyTransferError(err));
          };
        };
      };
    };

    public func balanceOf(account : Principal) : async Nat {
      await Icrc1Ledger.icrc1_balance_of(Account.defaultAccount(account));
    };
  };

  func formatIcrc1TransferError(err : Icrc1Ledger.Icrc1TransferError) : Text {
    switch (err) {
      case (#BadFee({ expected_fee })) {
        "bad_fee: expected " # Nat.toText(expected_fee);
      };
      case (#BadBurn({ min_burn_amount })) {
        "bad_burn: min " # Nat.toText(min_burn_amount);
      };
      case (#InsufficientFunds({ balance })) {
        "insufficient_funds: balance " # Nat.toText(balance);
      };
      case (#TooOld) "transfer_too_old";
      case (#CreatedInFuture({ ledger_time })) {
        "created_in_future: " # Nat64.toText(ledger_time);
      };
      case (#Duplicate({ duplicate_of })) {
        "duplicate_transfer: " # Nat.toText(duplicate_of);
      };
      case (#TemporarilyUnavailable) "ledger_temporarily_unavailable";
      case (#GenericError({ error_code; message })) {
        "ledger_error_" # Nat.toText(error_code) # ": " # message;
      };
    };
  };

  func formatLegacyTransferError(err : Icrc1Ledger.TransferError) : Text {
    switch (err) {
      case (#BadFee({ expected_fee })) {
        "bad_fee: expected " # Nat64.toText(expected_fee.e8s);
      };
      case (#InsufficientFunds({ balance })) {
        "insufficient_funds: balance " # Nat64.toText(balance.e8s);
      };
      case (#TxTooOld({ allowed_window_nanos })) {
        "transfer_too_old: " # Nat64.toText(allowed_window_nanos);
      };
      case (#TxCreatedInFuture) "created_in_future";
      case (#TxDuplicate({ duplicate_of })) {
        "duplicate_transfer: " # Nat64.toText(duplicate_of);
      };
    };
  };

  func formatTransferFromError(err : Icrc1Ledger.TransferFromError) : Text {
    switch (err) {
      case (#BadFee({ expected_fee })) {
        "bad_fee: expected " # Nat.toText(expected_fee);
      };
      case (#BadBurn({ min_burn_amount })) {
        "bad_burn: min " # Nat.toText(min_burn_amount);
      };
      case (#InsufficientFunds({ balance })) {
        "insufficient_funds: balance " # Nat.toText(balance);
      };
      case (#InsufficientAllowance({ allowance })) {
        "insufficient_allowance: " # Nat.toText(allowance);
      };
      case (#TooOld) "transfer_too_old";
      case (#CreatedInFuture({ ledger_time })) {
        "created_in_future: " # Nat64.toText(ledger_time);
      };
      case (#Duplicate({ duplicate_of })) {
        "duplicate_transfer: " # Nat.toText(duplicate_of);
      };
      case (#TemporarilyUnavailable) "ledger_temporarily_unavailable";
      case (#GenericError({ error_code; message })) {
        "ledger_error_" # Nat.toText(error_code) # ": " # message;
      };
    };
  };
};
