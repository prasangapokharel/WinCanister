import { suite; test } "mo:test/async";
import { expect } "mo:test";
import Principal "mo:core/Principal";
import Nat8 "mo:core/Nat8";
import AppConfig "mo:src/config/AppConfig";
import TestHarness "mo:src/testing/TestHarness";
import TestPrincipals "mo:src/testing/TestPrincipals";
import StableStorage "mo:src/storage/StableStorage";

suite("Upgrade Tests", func() : async () {
  let seed : [Nat8] = [1, 3, 5, 7, 9, 11, 13, 15];

  await test("state persistence", func() : async () {
    let harness = TestHarness.create(seed);
    let participant = TestPrincipals.participant1();
    TestHarness.fundParticipant(harness, participant, 500_000_000);
    ignore await harness.lotteryService.joinRound(participant, AppConfig.MIN_ENTRY_AMOUNT);
    let snapshot = StableStorage.toStable(harness.storage);
    let restored = TestHarness.restoreFromSnapshot(snapshot, seed);
    let entries = restored.entryRepo.getByRound(1);
    expect.nat(entries.size()).equal(1);
    expect.text(Principal.toText(entries[0].participant)).equal(Principal.toText(participant));
  });

  await test("statistics persistence", func() : async () {
    let harness = TestHarness.create(seed);
    let participant = TestPrincipals.participant1();
    TestHarness.fundParticipant(harness, participant, 500_000_000);
    ignore await harness.lotteryService.joinRound(participant, AppConfig.MIN_ENTRY_AMOUNT);
    let snapshot = StableStorage.toStable(harness.storage);
    let restored = TestHarness.restoreFromSnapshot(snapshot, seed);
    let stats = restored.lotteryService.getStatistics();
    expect.nat(stats.totalEntries).equal(1);
    expect.nat(stats.totalIcpCollected).equal(AppConfig.MIN_ENTRY_AMOUNT);
  });

  await test("payout persistence", func() : async () {
    let harness = TestHarness.create(seed);
    let participant = TestPrincipals.participant1();
    TestHarness.fundParticipant(harness, participant, 500_000_000);
    ignore await harness.lotteryService.joinRound(participant, AppConfig.MIN_ENTRY_AMOUNT);
    TestHarness.fundCanister(harness, 500_000_000);
    TestHarness.expireCurrentRound(harness);
    ignore await harness.lotteryService.processExpiredRound();
    let snapshot = StableStorage.toStable(harness.storage);
    let restored = TestHarness.restoreFromSnapshot(snapshot, seed);
    let payouts = restored.payoutRepo.getByRound(1);
    expect.bool(payouts.size() > 0).equal(true);
  });
});
