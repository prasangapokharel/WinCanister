import { suite; test } "mo:test/async";
import { expect } "mo:test";
import Nat8 "mo:core/Nat8";
import PrizeService "mo:src/services/PrizeService";
import Helpers "mo:src/utils/Helpers";
import AppConfig "mo:src/config/AppConfig";
import TestHarness "mo:src/testing/TestHarness";
import TestPrincipals "mo:src/testing/TestPrincipals";

suite("Prize Tests", func() : async () {
  await test("prize calculations", func() : async () {
    let total = 100_000_000_000;
    let prizePool = Helpers.calculatePrizePool(total);
    let breakdown = PrizeService.calculatePrizeBreakdown(prizePool, 3);
    expect.nat(breakdown.firstPlace).equal(prizePool * 60 / 100);
    expect.nat(breakdown.secondPlace).equal(prizePool * 25 / 100);
    expect.nat(breakdown.thirdPlace).equal(prizePool * 15 / 100);
  });

  await test("treasury calculations", func() : async () {
    let total = 100_000_000_000;
    let fee = Helpers.calculateTreasuryFee(total);
    expect.nat(fee).equal(total / 100);
    expect.nat(Helpers.calculatePrizePool(total)).equal(total - fee);
  });

  await test("payout execution", func() : async () {
    let seed : [Nat8] = [7, 14, 21, 28, 35, 42, 49, 56];
    let harness = TestHarness.create(seed);
    let participant = TestPrincipals.participant1();
    TestHarness.fundParticipant(harness, participant, 500_000_000);
    ignore await harness.lotteryService.joinRound(participant, AppConfig.MIN_ENTRY_AMOUNT);
    TestHarness.fundCanister(harness, 500_000_000);
    TestHarness.expireCurrentRound(harness);
    ignore await harness.lotteryService.processExpiredRound();
    let winners = harness.lotteryService.getWinnersByRound(1);
    expect.nat(winners.size()).equal(1);
    expect.bool(winners[0].paid).equal(true);
    let stats = harness.lotteryService.getStatistics();
    expect.nat(stats.totalPrizesPaid).greater(0);
  });
});
