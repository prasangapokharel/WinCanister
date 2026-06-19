import Principal "mo:core/Principal";
import Nat "mo:core/Nat";
import Nat64 "mo:core/Nat64";
import Result "mo:core/Result";
import LotteryService "../../services/LotteryService";
import Statistics "../../models/Statistics";
import Config "../../models/Config";

module {
  public class Controller(lotteryService : LotteryService.Service) {
    public func joinRound(caller : Principal, amount : Nat) : async Result.Result<Nat, Text> {
      await lotteryService.joinRound(caller, amount);
    };

    public func getStatistics() : Statistics.Statistics {
      lotteryService.getStatistics();
    };

    public func getTreasuryTotalTransferred() : Nat {
      lotteryService.getTreasuryTotalTransferred();
    };

    public func getConfig() : Config.Config {
      lotteryService.getConfig();
    };

    public func updateTreasury(caller : Principal, treasuryPrincipal : Principal) : Result.Result<Text, Text> {
      lotteryService.updateTreasury(caller, treasuryPrincipal);
    };

    public func processIncomingDeposits() : async Nat {
      await lotteryService.processIncomingDeposits();
    };

    public func adminRefundIcp(
      caller : Principal,
      recipient : Principal,
      amount : Nat,
      voidDepositTxId : ?Nat64,
    ) : async Result.Result<Nat, Text> {
      await lotteryService.adminRefundIcp(caller, recipient, amount, voidDepositTxId);
    };

    public func getCanisterIcpBalance() : async Nat {
      await lotteryService.getCanisterIcpBalance();
    };

    public func getUnclaimedIncomingTotal() : async Nat {
      await lotteryService.getUnclaimedIncomingTotal();
    };
  };
};
