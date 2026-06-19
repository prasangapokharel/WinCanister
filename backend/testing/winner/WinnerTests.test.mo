import { suite; test } "mo:test/async";
import { expect } "mo:test";
import Nat8 "mo:core/Nat8";
import AccountIdentifier "mo:src/utils/AccountIdentifier";
import WinnerService "mo:src/services/WinnerService";
import RawRandom "mo:src/randomness/RawRandom";
import TestPrincipals "mo:src/testing/TestPrincipals";

suite("Winner Tests", func() : async () {
  let seed : [Nat8] = [11, 22, 33, 44, 55, 66, 77, 88];

  await test("unique winners", func() : async () {
    let provider = RawRandom.DeterministicRandomProvider(seed);
    let service = WinnerService.Service(provider);
    let participants = [
      AccountIdentifier.toHex(TestPrincipals.participant1()),
      AccountIdentifier.toHex(TestPrincipals.participant2()),
      AccountIdentifier.toHex(TestPrincipals.participant3()),
      AccountIdentifier.toHex(TestPrincipals.participant4()),
    ];
    switch (await service.selectWinners(participants)) {
      case (#err(_)) assert false;
      case (#ok(winners)) {
        expect.nat(winners.size()).equal(3);
        let first = winners[0].accountHex;
        let second = winners[1].accountHex;
        let third = winners[2].accountHex;
        assert first != second;
        assert first != third;
        assert second != third;
      };
    };
  });

  await test("correct winner count", func() : async () {
    let provider = RawRandom.DeterministicRandomProvider(seed);
    let service = WinnerService.Service(provider);
    let one = [AccountIdentifier.toHex(TestPrincipals.participant1())];
    switch (await service.selectWinners(one)) {
      case (#ok(winners)) expect.nat(winners.size()).equal(1);
      case (#err(_)) assert false;
    };
    let two = [
      AccountIdentifier.toHex(TestPrincipals.participant1()),
      AccountIdentifier.toHex(TestPrincipals.participant2()),
    ];
    switch (await service.selectWinners(two)) {
      case (#ok(winners)) expect.nat(winners.size()).equal(2);
      case (#err(_)) assert false;
    };
  });
});
