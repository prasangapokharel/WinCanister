import Principal "mo:core/Principal";
import Nat "mo:core/Nat";

module {
  public type PayoutKind = {
    #Treasury;
    #Winner;
  };

  public type PayoutRecord = {
    roundId : Nat;
    recipient : Principal;
    amount : Nat;
    ledgerTxId : Nat;
    timestamp : Int;
    kind : PayoutKind;
    position : ?Nat;
  };

  public func newWinnerPayout(
    roundId : Nat,
    position : Nat,
    recipient : Principal,
    amount : Nat,
    ledgerTxId : Nat,
    timestamp : Int,
  ) : PayoutRecord {
    {
      roundId = roundId;
      recipient = recipient;
      amount = amount;
      ledgerTxId = ledgerTxId;
      timestamp = timestamp;
      kind = #Winner;
      position = ?position;
    };
  };

  public func newTreasuryPayout(
    roundId : Nat,
    recipient : Principal,
    amount : Nat,
    ledgerTxId : Nat,
    timestamp : Int,
  ) : PayoutRecord {
    {
      roundId = roundId;
      recipient = recipient;
      amount = amount;
      ledgerTxId = ledgerTxId;
      timestamp = timestamp;
      kind = #Treasury;
      position = null;
    };
  };
};
