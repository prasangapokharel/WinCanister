import Principal "mo:core/Principal";
import Nat "mo:core/Nat";
import Result "mo:core/Result";
import Blob "mo:core/Blob";
import RoundRepository "../repositories/RoundRepository";
import EntryRepository "../repositories/EntryRepository";
import AddressEntryRepository "../repositories/AddressEntryRepository";
import WinnerRepository "../repositories/WinnerRepository";
import TreasuryRepository "../repositories/TreasuryRepository";
import StatisticsRepository "../repositories/StatisticsRepository";
import ConfigRepository "../repositories/ConfigRepository";
import PayoutRepository "../repositories/PayoutRepository";
import ProcessedDepositRepository "../repositories/ProcessedDepositRepository";
import TransparencyService "TransparencyService";
import Round "../models/Round";
import Entry "../models/Entry";
import Winner "../models/Winner";
import Statistics "../models/Statistics";
import Config "../models/Config";
import EntryService "EntryService";
import RoundService "RoundService";
import TreasuryService "TreasuryService";
import ConfigService "ConfigService";
import WinnerService "WinnerService";
import DepositService "DepositService";
import IndexPort "../ledger/IndexPort";
import RawRandom "../randomness/RawRandom";

module {
  public type LedgerPort = {
    transferFrom : (Principal, Principal, Nat) -> async Result.Result<Nat, Text>;
    transfer : (Principal, Nat, ?Blob) -> async Result.Result<Nat, Text>;
    transferToAccountHex : (Text, Nat, ?Blob) -> async Result.Result<Nat, Text>;
    balanceOf : Principal -> async Nat;
  };

  public class Service(
    roundRepo : RoundRepository.Repository,
    entryRepo : EntryRepository.Repository,
    addressEntryRepo : AddressEntryRepository.Repository,
    winnerRepo : WinnerRepository.Repository,
    treasuryRepo : TreasuryRepository.Repository,
    statisticsRepo : StatisticsRepository.Repository,
    configRepo : ConfigRepository.Repository,
    payoutRepo : PayoutRepository.Repository,
    processedDepositRepo : ProcessedDepositRepository.Repository,
    ledger : LedgerPort,
    canisterPrincipal : Principal,
    indexPort : IndexPort.Port,
    randomProvider : RawRandom.RandomProvider,
  ) {
    let configService = ConfigService.Service(configRepo);
    let transparencyService = TransparencyService.Service(
      roundRepo,
      winnerRepo,
      addressEntryRepo,
      payoutRepo,
      statisticsRepo,
      configRepo,
    );
    let treasuryService = TreasuryService.Service(treasuryRepo, statisticsRepo);
    let winnerService = WinnerService.Service(randomProvider);
    let entryService = EntryService.Service(
      entryRepo,
      addressEntryRepo,
      roundRepo,
      statisticsRepo,
      treasuryService,
      ledger,
      canisterPrincipal,
    );
    let roundService = RoundService.Service(
      roundRepo,
      entryRepo,
      addressEntryRepo,
      winnerRepo,
      statisticsRepo,
      treasuryService,
      configService,
      transparencyService,
      winnerService,
      ledger,
    );
    let depositService = DepositService.Service(
      entryRepo,
      addressEntryRepo,
      roundRepo,
      statisticsRepo,
      processedDepositRepo,
      configRepo,
      treasuryService,
      indexPort,
      canisterPrincipal,
    );

    public func initialize() {
      roundService.createInitialRound();
    };

    public func joinRound(caller : Principal, amount : Nat) : async Result.Result<Nat, Text> {
      await entryService.joinRound(caller, amount);
    };

    public func processIncomingDeposits() : async Nat {
      await depositService.processIncomingDeposits();
    };

    public func adminRefundIcp(
      caller : Principal,
      recipient : Principal,
      amount : Nat,
      voidDepositTxId : ?Nat64,
    ) : async Result.Result<Nat, Text> {
      await depositService.adminRefundIcp(caller, recipient, amount, voidDepositTxId, ledger);
    };

    public func getCanisterIcpBalance() : async Nat {
      await ledger.balanceOf(canisterPrincipal);
    };

    public func getUnclaimedIncomingTotal() : async Nat {
      await depositService.getUnclaimedIncomingTotal();
    };

    public func getCurrentRound() : ?Round.Round {
      roundService.getCurrentRound();
    };

    public func processExpiredRound() : async Result.Result<Text, Text> {
      await roundService.processExpiredRound();
    };

    public func updateTreasury(caller : Principal, treasuryPrincipal : Principal) : Result.Result<Text, Text> {
      configService.updateTreasury(caller, treasuryPrincipal);
    };

    public func getConfig() : Config.Config {
      configService.getConfig();
    };

    public func getRoundHistory() : [Nat] {
      roundRepo.getHistory();
    };

    public func getWinnersByRound(roundId : Nat) : [Winner.Winner] {
      winnerRepo.getByRound(roundId);
    };

    public func getEntriesByRound(roundId : Nat) : [Entry.Entry] {
      entryRepo.getByRound(roundId);
    };

    public func getTreasuryTotalTransferred() : Nat {
      treasuryService.getTotalTransferred();
    };

    public func getStatistics() : Statistics.Statistics {
      statisticsRepo.get();
    };

    public func getTransparencyService() : TransparencyService.Service {
      transparencyService;
    };
  };
};
