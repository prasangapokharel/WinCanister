import Nat "mo:core/Nat";
import Text "mo:core/Text";
import Array "mo:core/Array";
import Result "mo:core/Result";
import Helpers "../utils/Helpers";
import AppConfig "../config/AppConfig";
import RawRandom "../randomness/RawRandom";

module {
  public type WinnerSelection = {
    position : Nat;
    accountHex : Text;
  };

  func removeAtIndex(participants : [Text], index : Nat) : [Text] {
    let before = Array.sliceToArray(participants, 0, index);
    let after = Array.sliceToArray(participants, index + 1, participants.size());
    Array.concat(before, after);
  };

  public class Service(randomProvider : RawRandom.RandomProvider) {
    public func selectWinners(participants : [Text]) : async Result.Result<[WinnerSelection], Text> {
      if (participants.size() == 0) {
        return #ok([]);
      };

      let winnerCount = Helpers.minNat(AppConfig.MAX_WINNERS, participants.size());
      var pool = participants;
      var winners : [WinnerSelection] = [];
      var position : Nat = 1;

      while (position <= winnerCount) {
        switch (await RawRandom.fetchRandom(randomProvider)) {
          case (#err(msg)) return #err(msg);
          case (#ok(bytes)) {
            let index = RawRandom.selectIndex(bytes, pool.size());
            let winner = pool[index];
            winners := Array.concat(winners, [{ position = position; accountHex = winner }]);
            pool := removeAtIndex(pool, index);
            position += 1;
          };
        };
      };

      #ok(winners);
    };
  };
};
