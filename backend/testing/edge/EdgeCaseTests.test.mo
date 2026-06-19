import { suite; test } "mo:test/async";
import { expect } "mo:test";
import Principal "mo:core/Principal";
import Nat "mo:core/Nat";
import Nat8 "mo:core/Nat8";
import Blob "mo:core/Blob";
import Array "mo:core/Array";
import AppConfig "mo:src/config/AppConfig";
import TestHarness "mo:src/testing/TestHarness";
import TestPrincipals "mo:src/testing/TestPrincipals";

suite("Edge Case Tests", func() : async () {
  let seed : [Nat8] = [5, 10, 15, 20, 25, 30, 35, 40];

  func makePrincipal(n : Nat) : Principal {
    let bytes = Array.tabulate<Nat8>(29, func(i) { Nat8.fromNat((n + i) % 256) });
    Principal.fromBlob(Blob.fromArray(bytes));
  };

  func completeRound(harness : TestHarness.Harness) : async () {
    TestHarness.fundCanister(harness, 10_000_000_000);
    TestHarness.expireCurrentRound(harness);
    ignore await harness.lotteryService.processExpiredRound();
  };

  await test("zero participants", func() : async () {
    let harness = TestHarness.create(seed);
    await completeRound(harness);
    let winners = harness.lotteryService.getWinnersByRound(1);
    expect.nat(winners.size()).equal(0);
    switch (harness.lotteryService.getCurrentRound()) {
      case null assert false;
      case (?round) expect.nat(round.id).equal(2);
    };
  });

  await test("one participant", func() : async () {
    let harness = TestHarness.create(seed);
    let participant = TestPrincipals.participant1();
    TestHarness.fundParticipant(harness, participant, 500_000_000);
    ignore await harness.lotteryService.joinRound(participant, AppConfig.MIN_ENTRY_AMOUNT);
    await completeRound(harness);
    let winners = harness.lotteryService.getWinnersByRound(1);
    expect.nat(winners.size()).equal(1);
    expect.nat(winners[0].prizeAmount).greater(0);
    expect.bool(winners[0].paid).equal(true);
  });

  await test("two participants", func() : async () {
    let harness = TestHarness.create(seed);
    let p1 = TestPrincipals.participant1();
    let p2 = TestPrincipals.participant2();
    TestHarness.fundParticipant(harness, p1, 500_000_000);
    TestHarness.fundParticipant(harness, p2, 500_000_000);
    ignore await harness.lotteryService.joinRound(p1, AppConfig.MIN_ENTRY_AMOUNT);
    ignore await harness.lotteryService.joinRound(p2, AppConfig.MIN_ENTRY_AMOUNT);
    await completeRound(harness);
    let winners = harness.lotteryService.getWinnersByRound(1);
    expect.nat(winners.size()).equal(2);
  });

  await test("three participants", func() : async () {
    let harness = TestHarness.create(seed);
    let participants = [
      TestPrincipals.participant1(),
      TestPrincipals.participant2(),
      TestPrincipals.participant3(),
    ];
    for (p in participants.vals()) {
      TestHarness.fundParticipant(harness, p, 500_000_000);
      ignore await harness.lotteryService.joinRound(p, AppConfig.MIN_ENTRY_AMOUNT);
    };
    await completeRound(harness);
    let winners = harness.lotteryService.getWinnersByRound(1);
    expect.nat(winners.size()).equal(3);
  });

  await test("massive participant count", func() : async () {
    let harness = TestHarness.create(seed);
    var i : Nat = 0;
    while (i < 50) {
      let p = makePrincipal(i + 10);
      TestHarness.fundParticipant(harness, p, 500_000_000);
      ignore await harness.lotteryService.joinRound(p, AppConfig.MIN_ENTRY_AMOUNT);
      i += 1;
    };
    expect.nat(harness.entryRepo.countByRound(1)).equal(50);
    await completeRound(harness);
    let winners = harness.lotteryService.getWinnersByRound(1);
    expect.nat(winners.size()).equal(3);
  });
});
