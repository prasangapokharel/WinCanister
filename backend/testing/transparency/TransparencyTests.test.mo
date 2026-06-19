import { suite; test } "mo:test/async";
import { expect } "mo:test";
import Nat8 "mo:core/Nat8";
import AppConfig "mo:src/config/AppConfig";
import TestHarness "mo:src/testing/TestHarness";
import TestPrincipals "mo:src/testing/TestPrincipals";

suite("Transparency Tests", func() : async () {
  let seed : [Nat8] = [1, 2, 3, 4, 5, 6, 7, 8];

  await test("getCurrentRound public response", func() : async () {
    let harness = TestHarness.create(seed);
    let transparency = harness.lotteryService.getTransparencyService();
    switch (transparency.getCurrentRoundPublic()) {
      case null assert false;
      case (?round) {
        expect.nat(round.roundId).equal(1);
        expect.text(round.status).equal("OPEN");
      };
    };
  });

  await test("getPayouts records ledger tx ids", func() : async () {
    let harness = TestHarness.create(seed);
    let participant = TestPrincipals.participant1();
    TestHarness.fundParticipant(harness, participant, 500_000_000);
    ignore await harness.lotteryService.joinRound(participant, AppConfig.MIN_ENTRY_AMOUNT);
    TestHarness.fundCanister(harness, 500_000_000);
    TestHarness.expireCurrentRound(harness);
    ignore await harness.lotteryService.processExpiredRound();
    let transparency = harness.lotteryService.getTransparencyService();
    switch (transparency.getPayouts(1)) {
      case null assert false;
      case (?payouts) {
        switch (payouts.winner1) {
          case null assert false;
          case (?w) {
            expect.bool(w.paid).equal(true);
            expect.nat(w.txId).greater(0);
          };
        };
        switch (payouts.treasury) {
          case null assert false;
          case (?t) expect.nat(t.txId).greater(0);
        };
      };
    };
  });
});
