import Nat "mo:core/Nat";
import Principal "mo:core/Principal";
import Result "mo:core/Result";
import TreasuryRepository "../repositories/TreasuryRepository";
import StatisticsRepository "../repositories/StatisticsRepository";
import Helpers "../utils/Helpers";
import Logger "../utils/Logger";

module {
  public type LedgerPort = {
    transfer : (Principal, Nat, ?Blob) -> async Result.Result<Nat, Text>;
  };

  public class Service(
    treasuryRepo : TreasuryRepository.Repository,
    statisticsRepo : StatisticsRepository.Repository,
  ) {
    public func recordAccruedFee(amount : Nat) {
      let fee = Helpers.calculateTreasuryFee(amount);
      let treasury = treasuryRepo.get();
      treasuryRepo.set({
        treasury with totalAccrued = treasury.totalAccrued + fee;
      });
      let stats = statisticsRepo.get();
      statisticsRepo.set({
        stats with totalIcpCollected = stats.totalIcpCollected + amount;
      });
      Logger.event("treasury_fee_accrued", Nat.toText(fee));
    };

    public func transferTreasury(
      ledger : LedgerPort,
      treasuryPrincipal : Principal,
      amount : Nat,
    ) : async Result.Result<Nat, Text> {
      if (amount == 0) {
        return #ok(0);
      };
      switch (await ledger.transfer(treasuryPrincipal, amount, null)) {
        case (#err(msg)) #err(msg);
        case (#ok(blockIndex)) {
          let treasury = treasuryRepo.get();
          treasuryRepo.set({
            treasury with totalTransferred = treasury.totalTransferred + amount;
          });
          let stats = statisticsRepo.get();
          statisticsRepo.set({
            stats with totalTreasuryTransferred = stats.totalTreasuryTransferred + amount;
          });
          Logger.event("treasury_transferred", Nat.toText(amount));
          #ok(blockIndex);
        };
      };
    };

    public func getTotalTransferred() : Nat {
      treasuryRepo.get().totalTransferred;
    };
  };
};
