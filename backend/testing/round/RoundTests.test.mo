import { suite; test } "mo:test/async";
import { expect } "mo:test";
import Nat8 "mo:core/Nat8";
import AppConfig "mo:src/config/AppConfig";
import TestHarness "mo:src/testing/TestHarness";
import TestPrincipals "mo:src/testing/TestPrincipals";

suite("Round Tests", func() : async () {
  let seed : [Nat8] = [9, 8, 7, 6, 5, 4, 3, 2];

  await test("create round", func() : async () {
    let harness = TestHarness.create(seed);
    switch (harness.lotteryService.getCurrentRound()) {
      case null assert false;
      case (?round) {
        expect.nat(round.id).equal(1);
        expect.bool(round.status == #AcceptEntries).equal(true);
      };
    };
  });

  await test("close round", func() : async () {
    let harness = TestHarness.create(seed);
    TestHarness.expireCurrentRound(harness);
    ignore await harness.lotteryService.processExpiredRound();
    switch (harness.lotteryService.getCurrentRound()) {
      case null assert false;
      case (?round) expect.nat(round.id).equal(2);
    };
  });

  await test("archive round and create next round", func() : async () {
    let harness = TestHarness.create(seed);
    let participant = TestPrincipals.participant1();
    TestHarness.fundParticipant(harness, participant, 500_000_000);
    ignore await harness.lotteryService.joinRound(participant, AppConfig.MIN_ENTRY_AMOUNT);
    TestHarness.fundCanister(harness, 500_000_000);
    TestHarness.expireCurrentRound(harness);
    ignore await harness.lotteryService.processExpiredRound();
    let history = harness.lotteryService.getRoundHistory();
    expect.nat(history.size()).equal(1);
    expect.nat(history[0]).equal(1);
    switch (harness.lotteryService.getCurrentRound()) {
      case null assert false;
      case (?round) expect.nat(round.id).equal(2);
    };
  });
});
