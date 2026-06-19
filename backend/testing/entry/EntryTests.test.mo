import { suite; test } "mo:test/async";
import { expect } "mo:test";
import Nat8 "mo:core/Nat8";
import AppConfig "mo:src/config/AppConfig";
import TestHarness "mo:src/testing/TestHarness";
import TestPrincipals "mo:src/testing/TestPrincipals";

suite("Entry Tests", func() : async () {
  let seed : [Nat8] = [1, 2, 3, 4, 5, 6, 7, 8];
  let participant = TestPrincipals.participant1();

  await test("valid entry", func() : async () {
    let harness = TestHarness.create(seed);
    TestHarness.fundParticipant(harness, participant, 500_000_000);
    let result = await harness.lotteryService.joinRound(participant, AppConfig.MIN_ENTRY_AMOUNT);
    switch (result) {
      case (#ok(_)) {};
      case (#err(_)) assert false;
    };
    let entries = harness.entryRepo.getByRound(1);
    expect.nat(entries.size()).equal(1);
  });

  await test("duplicate entry", func() : async () {
    let harness = TestHarness.create(seed);
    TestHarness.fundParticipant(harness, participant, 1_000_000_000);
    ignore await harness.lotteryService.joinRound(participant, AppConfig.MIN_ENTRY_AMOUNT);
    let result = await harness.lotteryService.joinRound(participant, AppConfig.MIN_ENTRY_AMOUNT);
    switch (result) {
      case (#err(msg)) expect.text(msg).equal("duplicate_entry");
      case (#ok(_)) assert false;
    };
  });

  await test("invalid amount", func() : async () {
    let harness = TestHarness.create(seed);
    TestHarness.fundParticipant(harness, participant, 500_000_000);
    let result = await harness.lotteryService.joinRound(participant, 50_000_000);
    switch (result) {
      case (#err(msg)) expect.text(msg).equal("amount_below_minimum");
      case (#ok(_)) assert false;
    };
  });

  await test("closed round", func() : async () {
    let harness = TestHarness.create(seed);
    TestHarness.fundParticipant(harness, participant, 500_000_000);
    let roundId = harness.roundRepo.getCurrentRoundId();
    switch (harness.roundRepo.findById(roundId)) {
      case (?round) {
        harness.roundRepo.save({ round with status = #RoundClose });
      };
      case null {};
    };
    let result = await harness.lotteryService.joinRound(participant, AppConfig.MIN_ENTRY_AMOUNT);
    switch (result) {
      case (#err(msg)) expect.text(msg).equal("round_not_accepting_entries");
      case (#ok(_)) assert false;
    };
  });
});
