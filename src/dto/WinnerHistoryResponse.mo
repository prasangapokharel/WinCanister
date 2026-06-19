import Principal "mo:core/Principal";
import Nat "mo:core/Nat";
import Winner "../models/Winner";

module {
  public type WinnerHistoryEntry = {
    roundId : Nat;
    winner1 : ?Principal;
    winner2 : ?Principal;
    winner3 : ?Principal;
  };

  public func fromWinners(roundId : Nat, winners : [Winner.Winner]) : WinnerHistoryEntry {
    {
      roundId = roundId;
      winner1 = findWinner(winners, 1);
      winner2 = findWinner(winners, 2);
      winner3 = findWinner(winners, 3);
    };
  };

  func findWinner(winners : [Winner.Winner], position : Nat) : ?Principal {
    for (winner in winners.vals()) {
      if (winner.position == position) {
        return ?winner.participant;
      };
    };
    null;
  };
};
