import { suite; test } "mo:test/async";
import { expect } "mo:test";
import Nat8 "mo:core/Nat8";
import AppConfig "mo:src/config/AppConfig";
import TestHarness "mo:src/testing/TestHarness";
import TestPrincipals "mo:src/testing/TestPrincipals";
import Helpers "mo:src/utils/Helpers";

suite("Treasury Tests", func() : async () {
  let seed : [Nat8] = [3, 6, 9, 12, 15, 18, 21, 24];

  await test("fee calculation", func() : async () {
    let total = 200_000_000;
    let fee = Helpers.calculateTreasuryFee(total);
    expect.nat(fee).equal(2_000_000);
  });

  await test("fee transfer on round close", func() : async () {
    let harness = TestHarness.create(seed);
    let participant = TestPrincipals.participant1();
    let treasury = harness.lotteryService.getConfig().treasuryPrincipal;
    TestHarness.fundParticipant(harness, participant, 500_000_000);
    ignore await harness.lotteryService.joinRound(participant, AppConfig.MIN_ENTRY_AMOUNT);
    TestHarness.fundCanister(harness, 500_000_000);
    TestHarness.expireCurrentRound(harness);
    ignore await harness.lotteryService.processExpiredRound();
    let transferred = harness.lotteryService.getTreasuryTotalTransferred();
    expect.nat(transferred).greater(0);
    let treasuryBalance = await harness.ledger.balanceOf(treasury);
    expect.nat(treasuryBalance).greater(0);
  });
});
