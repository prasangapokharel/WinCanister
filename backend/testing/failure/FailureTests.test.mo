import { suite; test } "mo:test/async";
import { expect } "mo:test";
import Nat8 "mo:core/Nat8";
import AppConfig "mo:src/config/AppConfig";
import TestHarness "mo:src/testing/TestHarness";
import TestPrincipals "mo:src/testing/TestPrincipals";

suite("Failure Tests", func() : async () {
  let seed : [Nat8] = [2, 4, 6, 8, 10, 12, 14, 16];

  await test("ledger failure", func() : async () {
    let harness = TestHarness.create(seed);
    let participant = TestPrincipals.participant1();
    TestHarness.fundParticipant(harness, participant, 500_000_000);
    harness.ledger.setTransferFromFailure(true);
    let result = await harness.lotteryService.joinRound(participant, AppConfig.MIN_ENTRY_AMOUNT);
    switch (result) {
      case (#err(msg)) expect.text(msg).equal("mock_transfer_from_failed");
      case (#ok(_)) assert false;
    };
  });

  await test("payout failure", func() : async () {
    let harness = TestHarness.create(seed);
    let participant = TestPrincipals.participant1();
    TestHarness.fundParticipant(harness, participant, 500_000_000);
    ignore await harness.lotteryService.joinRound(participant, AppConfig.MIN_ENTRY_AMOUNT);
    TestHarness.expireCurrentRound(harness);
    harness.ledger.setTransferFailure(true);
    let result = await harness.lotteryService.processExpiredRound();
    switch (result) {
      case (#err(msg)) expect.text(msg).equal("mock_transfer_failed");
      case (#ok(_)) assert false;
    };
  });

  await test("insufficient funds", func() : async () {
    let harness = TestHarness.create(seed);
    let result = await harness.lotteryService.joinRound(
      TestPrincipals.participant1(),
      AppConfig.MIN_ENTRY_AMOUNT,
    );
    switch (result) {
      case (#err(msg)) expect.text(msg).equal("insufficient_funds: balance 0");
      case (#ok(_)) assert false;
    };
  });
});
