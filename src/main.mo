import Principal "mo:core/Principal";
import Nat "mo:core/Nat";
import Blob "mo:core/Blob";
import Result "mo:core/Result";
import Timer "mo:core/Timer";
import StableStorage "storage/StableStorage";
import RoundRepository "repositories/RoundRepository";
import EntryRepository "repositories/EntryRepository";
import WinnerRepository "repositories/WinnerRepository";
import TreasuryRepository "repositories/TreasuryRepository";
import StatisticsRepository "repositories/StatisticsRepository";
import ConfigRepository "repositories/ConfigRepository";
import PayoutRepository "repositories/PayoutRepository";
import ProcessedDepositRepository "repositories/ProcessedDepositRepository";
import AddressEntryRepository "repositories/AddressEntryRepository";
import LedgerClient "ledger/LedgerClient";
import IcpIndexClient "ledger/IcpIndexClient";
import RawRandom "randomness/RawRandom";
import LotteryService "services/LotteryService";
import LotteryController "api/v1/LotteryController";
import RoundController "api/v1/RoundController";
import WinnerController "api/v1/WinnerController";
import HealthController "api/v1/HealthController";
import WinnerResponse "dto/WinnerResponse";
import PublicCurrentRoundResponse "dto/PublicCurrentRoundResponse";
import RoundResultResponse "dto/RoundResultResponse";
import PayoutDetailsResponse "dto/PayoutDetailsResponse";
import PublicStatisticsResponse "dto/PublicStatisticsResponse";
import WinnerHistoryResponse "dto/WinnerHistoryResponse";
import Statistics "models/Statistics";
import Config "models/Config";
import Logger "utils/Logger";

actor Lottery {
  var storage : StableStorage.Store;
  var isInitialized : Bool;
  transient var unclaimedIncomingTotalE8s = 0;

  func buildLotteryService() : LotteryService.Service {
    let ledgerClient = LedgerClient.Client();
    let randomProvider = RawRandom.IcpRandomProvider();
    let canisterPrincipal = Principal.fromActor(Lottery);
    let ledgerPort = {
      transferFrom = func(from : Principal, to : Principal, amount : Nat) : async Result.Result<Nat, Text> {
        await ledgerClient.transferFrom(from, to, amount);
      };
      transfer = func(to : Principal, amount : Nat, fromSubaccount : ?Blob) : async Result.Result<Nat, Text> {
        await ledgerClient.transfer(to, amount, fromSubaccount);
      };
      transferToAccountHex = func(accountHex : Text, amount : Nat, fromSubaccount : ?Blob) : async Result.Result<Nat, Text> {
        await ledgerClient.transferToAccountHex(accountHex, amount, fromSubaccount);
      };
      balanceOf = func(account : Principal) : async Nat {
        await ledgerClient.balanceOf(account);
      };
    };
    LotteryService.Service(
      RoundRepository.Repository(storage.rounds),
      EntryRepository.Repository(storage.entries),
      AddressEntryRepository.Repository(storage.addressEntries),
      WinnerRepository.Repository(storage.winners),
      TreasuryRepository.Repository(storage.treasury),
      StatisticsRepository.Repository(storage.statistics),
      ConfigRepository.Repository(storage.config),
      PayoutRepository.Repository(storage.payouts),
      ProcessedDepositRepository.Repository(storage.processedDeposits),
      ledgerPort,
      canisterPrincipal,
      IcpIndexClient.Client(),
      randomProvider,
    );
  };

  func ensureInitialized<system>() {
    if (not isInitialized) {
      buildLotteryService().initialize();
      scheduleRoundCheck<system>();
      scheduleDepositWatch<system>();
      isInitialized := true;
      Logger.info("lottery initialized");
    };
  };

  func scheduleDepositWatch<system>() {
    ignore Timer.recurringTimer<system>(
      #seconds (30),
      func() : async () {
        let controller = LotteryController.Controller(buildLotteryService());
        ignore await controller.processIncomingDeposits();
        let total = await controller.getUnclaimedIncomingTotal();
        unclaimedIncomingTotalE8s := total;
      },
    );
  };

  func scheduleRoundCheck<system>() {
    ignore Timer.recurringTimer<system>(
      #seconds (60),
      func() : async () {
        ignore await RoundController.Controller(buildLotteryService()).processExpiredRound();
      },
    );
  };

  public shared (msg) func joinRound(amount : Nat) : async Result.Result<Nat, Text> {
    ensureInitialized<system>();
    await LotteryController.Controller(buildLotteryService()).joinRound(msg.caller, amount);
  };

  public query func getCurrentRound() : async ?PublicCurrentRoundResponse.PublicCurrentRoundResponse {
    buildLotteryService().getTransparencyService().getCurrentRoundPublic();
  };

  public query func getRoundResult(roundId : Nat) : async ?RoundResultResponse.RoundResultResponse {
    buildLotteryService().getTransparencyService().getRoundResult(roundId);
  };

  public query func getPayouts(roundId : Nat) : async ?PayoutDetailsResponse.PayoutDetailsResponse {
    buildLotteryService().getTransparencyService().getPayouts(roundId);
  };

  public query func getStatistics() : async PublicStatisticsResponse.PublicStatisticsResponse {
    buildLotteryService().getTransparencyService().getPublicStatistics();
  };

  public query func getWinnerHistory() : async [WinnerHistoryResponse.WinnerHistoryEntry] {
    buildLotteryService().getTransparencyService().getWinnerHistory();
  };

  public query func getRoundHistory() : async [Nat] {
    RoundController.Controller(buildLotteryService()).getRoundHistory();
  };

  public query func getWinnersByRound(roundId : Nat) : async [WinnerResponse.WinnerResponse] {
    WinnerController.Controller(buildLotteryService()).getWinnersByRound(roundId);
  };

  public query func getTreasuryTotalTransferred() : async Nat {
    LotteryController.Controller(buildLotteryService()).getTreasuryTotalTransferred();
  };

  public query func getInternalStatistics() : async Statistics.Statistics {
    LotteryController.Controller(buildLotteryService()).getStatistics();
  };

  public query func getConfig() : async Config.Config {
    LotteryController.Controller(buildLotteryService()).getConfig();
  };

  public shared (msg) func updateTreasury(treasuryPrincipal : Principal) : async Result.Result<Text, Text> {
    ensureInitialized<system>();
    LotteryController.Controller(buildLotteryService()).updateTreasury(msg.caller, treasuryPrincipal);
  };

  public shared (_msg) func processIncomingDeposits() : async Nat {
    ensureInitialized<system>();
    await LotteryController.Controller(buildLotteryService()).processIncomingDeposits();
  };

  public shared (_msg) func syncDepositWatch() : async Nat {
    ensureInitialized<system>();
    let controller = LotteryController.Controller(buildLotteryService());
    ignore await controller.processIncomingDeposits();
    let total = await controller.getUnclaimedIncomingTotal();
    unclaimedIncomingTotalE8s := total;
    total;
  };

  public shared (msg) func adminRefundIcp(
    recipient : Principal,
    amount : Nat,
    voidDepositTxId : ?Nat64,
  ) : async Result.Result<Nat, Text> {
    ensureInitialized<system>();
    await LotteryController.Controller(buildLotteryService()).adminRefundIcp(
      msg.caller,
      recipient,
      amount,
      voidDepositTxId,
    );
  };

  public shared func getCanisterIcpBalance() : async Nat {
    ensureInitialized<system>();
    await LotteryController.Controller(buildLotteryService()).getCanisterIcpBalance();
  };

  public query func getUnclaimedIncomingTotal() : async Nat {
    unclaimedIncomingTotalE8s;
  };

  public query func health() : async HealthController.HealthResponse {
    HealthController.health();
  };

  public shared (_msg) func processExpiredRound() : async Result.Result<Text, Text> {
    ensureInitialized<system>();
    await RoundController.Controller(buildLotteryService()).processExpiredRound();
  };

  public shared (_msg) func initialize() : async () {
    ensureInitialized<system>();
  };
};