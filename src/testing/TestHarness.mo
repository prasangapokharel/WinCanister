import Principal "mo:core/Principal";
import Nat "mo:core/Nat";
import Nat8 "mo:core/Nat8";
import Text "mo:core/Text";
import Blob "mo:core/Blob";
import Result "mo:core/Result";
import StableStorage "../storage/StableStorage";
import AppConfig "../config/AppConfig";
import TimeUtil "../utils/TimeUtil";
import TestPrincipals "./TestPrincipals";
import RoundRepository "../repositories/RoundRepository";
import EntryRepository "../repositories/EntryRepository";
import WinnerRepository "../repositories/WinnerRepository";
import TreasuryRepository "../repositories/TreasuryRepository";
import StatisticsRepository "../repositories/StatisticsRepository";
import ConfigRepository "../repositories/ConfigRepository";
import PayoutRepository "../repositories/PayoutRepository";
import ProcessedDepositRepository "../repositories/ProcessedDepositRepository";
import AddressEntryRepository "../repositories/AddressEntryRepository";
import MockLedgerClient "../ledger/MockLedgerClient";
import MockIndexClient "../ledger/MockIndexClient";
import RawRandom "../randomness/RawRandom";
import LotteryService "../services/LotteryService";

module {
  public type Harness = {
    storage : StableStorage.Store;
    roundRepo : RoundRepository.Repository;
    entryRepo : EntryRepository.Repository;
    addressEntryRepo : AddressEntryRepository.Repository;
    winnerRepo : WinnerRepository.Repository;
    treasuryRepo : TreasuryRepository.Repository;
    statisticsRepo : StatisticsRepository.Repository;
    configRepo : ConfigRepository.Repository;
    payoutRepo : PayoutRepository.Repository;
    ledger : MockLedgerClient.Client;
    index : MockIndexClient.Client;
    lotteryService : LotteryService.Service;
    canisterPrincipal : Principal;
  };

  func buildHarness(storage : StableStorage.Store, seedBytes : [Nat8], initialize : Bool) : Harness {
    let roundRepo = RoundRepository.Repository(storage.rounds);
    let entryRepo = EntryRepository.Repository(storage.entries);
    let addressEntryRepo = AddressEntryRepository.Repository(storage.addressEntries);
    let winnerRepo = WinnerRepository.Repository(storage.winners);
    let treasuryRepo = TreasuryRepository.Repository(storage.treasury);
    let statisticsRepo = StatisticsRepository.Repository(storage.statistics);
    let configRepo = ConfigRepository.Repository(storage.config);
    let payoutRepo = PayoutRepository.Repository(storage.payouts);
    let processedDepositRepo = ProcessedDepositRepository.Repository(storage.processedDeposits);
    let ledger = MockLedgerClient.Client();
    let index = MockIndexClient.Client();
    let canisterPrincipal = TestPrincipals.canisterOwner();
    ledger.setCanisterOwner(canisterPrincipal);
    let randomProvider = RawRandom.DeterministicRandomProvider(seedBytes);
    let ledgerPort = {
      transferFrom = func(from : Principal, to : Principal, amount : Nat) : async Result.Result<Nat, Text> {
        await ledger.transferFrom(from, to, amount);
      };
      transfer = func(to : Principal, amount : Nat, fromSubaccount : ?Blob) : async Result.Result<Nat, Text> {
        await ledger.transfer(to, amount, fromSubaccount);
      };
      transferToAccountHex = func(accountHex : Text, amount : Nat, fromSubaccount : ?Blob) : async Result.Result<Nat, Text> {
        await ledger.transferToAccountHex(accountHex, amount, fromSubaccount);
      };
      balanceOf = func(account : Principal) : async Nat {
        await ledger.balanceOf(account);
      };
    };
    let lotteryService = LotteryService.Service(
      roundRepo,
      entryRepo,
      addressEntryRepo,
      winnerRepo,
      treasuryRepo,
      statisticsRepo,
      configRepo,
      payoutRepo,
      processedDepositRepo,
      ledgerPort,
      canisterPrincipal,
      index,
      randomProvider,
    );
    if (initialize) {
      lotteryService.initialize();
    };
    {
      storage = storage;
      roundRepo = roundRepo;
      entryRepo = entryRepo;
      addressEntryRepo = addressEntryRepo;
      winnerRepo = winnerRepo;
      treasuryRepo = treasuryRepo;
      statisticsRepo = statisticsRepo;
      configRepo = configRepo;
      payoutRepo = payoutRepo;
      ledger = ledger;
      index = index;
      lotteryService = lotteryService;
      canisterPrincipal = canisterPrincipal;
    };
  };

  public func create(seedBytes : [Nat8]) : Harness {
    buildHarness(StableStorage.empty(), seedBytes, true);
  };

  public func restoreFromSnapshot(snapshot : StableStorage.StableData, seedBytes : [Nat8]) : Harness {
    buildHarness(StableStorage.fromStable(snapshot), seedBytes, false);
  };

  public func expireCurrentRound(h : Harness) {
    let roundId = h.roundRepo.getCurrentRoundId();
    switch (h.roundRepo.findById(roundId)) {
      case (?round) {
        let now = TimeUtil.now();
        let expired = {
          round with
          startTime = now - AppConfig.ROUND_DURATION_NS - 1;
          endTime = now - 1;
        };
        h.roundRepo.save(expired);
      };
      case null {};
    };
  };

  public func fundParticipant(h : Harness, participant : Principal, amount : Nat) {
    h.ledger.setBalance(participant, amount);
  };

  public func fundCanister(h : Harness, amount : Nat) {
    h.ledger.setBalance(h.canisterPrincipal, amount);
  };
};
