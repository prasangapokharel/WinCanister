import { suite; test } "mo:test/async";
import { expect } "mo:test";
import Nat8 "mo:core/Nat8";
import Nat64 "mo:core/Nat64";
import AppConfig "mo:src/config/AppConfig";
import AccountIdentifier "mo:src/utils/AccountIdentifier";
import TestHarness "mo:src/testing/TestHarness";
import TestPrincipals "mo:src/testing/TestPrincipals";

suite("Deposit Tests", func() : async () {
  let seed : [Nat8] = [1, 2, 3, 4, 5, 6, 7, 8];
  let participant = TestPrincipals.participant1();
  let accountHex = AccountIdentifier.toHex(participant);

  await test("auto credit deposit from account transfer", func() : async () {
    let harness = TestHarness.create(seed);
    harness.index.addTransfer({
      txId = Nat64.fromNat(37077481);
      fromAccountHex = accountHex;
      amountE8s = AppConfig.MIN_ENTRY_AMOUNT;
    });

    let credited = await harness.lotteryService.processIncomingDeposits();
    expect.nat(credited).equal(1);
    expect.nat(harness.addressEntryRepo.countByRound(1)).equal(1);
  });

  await test("skip duplicate account in same round", func() : async () {
    let harness = TestHarness.create(seed);
    harness.index.addTransfer({
      txId = Nat64.fromNat(99);
      fromAccountHex = accountHex;
      amountE8s = AppConfig.MIN_ENTRY_AMOUNT;
    });
    harness.index.addTransfer({
      txId = Nat64.fromNat(100);
      fromAccountHex = accountHex;
      amountE8s = AppConfig.MIN_ENTRY_AMOUNT;
    });

    let credited = await harness.lotteryService.processIncomingDeposits();
    expect.nat(credited).equal(1);
    expect.nat(harness.addressEntryRepo.countByRound(1)).equal(1);
  });

  await test("ignore transfers below minimum", func() : async () {
    let harness = TestHarness.create(seed);
    harness.index.addTransfer({
      txId = Nat64.fromNat(101);
      fromAccountHex = AccountIdentifier.toHex(TestPrincipals.participant2());
      amountE8s = 50_000_000;
    });

    let credited = await harness.lotteryService.processIncomingDeposits();
    expect.nat(credited).equal(0);
  });
});
