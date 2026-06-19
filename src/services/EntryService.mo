import Principal "mo:core/Principal";
import Nat "mo:core/Nat";
import Result "mo:core/Result";
import Blob "mo:core/Blob";
import EntryRepository "../repositories/EntryRepository";
import AddressEntryRepository "../repositories/AddressEntryRepository";
import RoundRepository "../repositories/RoundRepository";
import StatisticsRepository "../repositories/StatisticsRepository";
import Entry "../models/Entry";
import Round "../models/Round";
import EntryValidator "../validators/EntryValidator";
import TimeUtil "../utils/TimeUtil";
import Helpers "../utils/Helpers";
import Logger "../utils/Logger";
import AccountIdentifier "../utils/AccountIdentifier";
import TreasuryService "TreasuryService";

module {
  public type LedgerPort = {
    transferFrom : (Principal, Principal, Nat) -> async Result.Result<Nat, Text>;
  };

  public class Service(
    entryRepo : EntryRepository.Repository,
    addressEntryRepo : AddressEntryRepository.Repository,
    roundRepo : RoundRepository.Repository,
    statisticsRepo : StatisticsRepository.Repository,
    treasuryService : TreasuryService.Service,
    ledger : LedgerPort,
    canisterPrincipal : Principal,
  ) {
    public func joinRound(caller : Principal, amount : Nat) : async Result.Result<Nat, Text> {
      switch (EntryValidator.validateCaller(caller)) {
        case (?err) return #err(err);
        case null {};
      };
      switch (EntryValidator.validateAmount(amount)) {
        case (?err) return #err(err);
        case null {};
      };

      let accountHex = AccountIdentifier.toHex(caller);
      let roundId = roundRepo.getCurrentRoundId();
      switch (roundRepo.findById(roundId)) {
        case null return #err("no_active_round");
        case (?round) {
          switch (EntryValidator.validateRoundAcceptingEntries(round)) {
            case (?err) return #err(err);
            case null {};
          };
          switch (entryRepo.findByRoundAndParticipant(roundId, caller)) {
            case (?_) return #err("duplicate_entry");
            case null {};
          };
          switch (addressEntryRepo.findByRoundAndAccountHex(roundId, accountHex)) {
            case (?_) return #err("duplicate_entry");
            case null {};
          };

          switch (await ledger.transferFrom(caller, canisterPrincipal, amount)) {
            case (#err(msg)) return #err(msg);
            case (#ok(_)) {};
          };

          creditEntry(caller, amount, roundId);
        };
      };
    };

    func creditEntry(caller : Principal, amount : Nat, roundId : Nat) : Result.Result<Nat, Text> {
      switch (roundRepo.findById(roundId)) {
        case null return #err("no_active_round");
        case (?round) {
          let entry = Entry.newEntry(roundId, caller, amount, TimeUtil.now());
          entryRepo.save(entry);

          let treasuryFee = Helpers.calculateTreasuryFee(amount);
          let prizeContribution = amount - treasuryFee;
          treasuryService.recordAccruedFee(amount);

          let updatedRound = {
            round with
            totalCollected = round.totalCollected + amount;
            entryCount = round.entryCount + 1;
            treasuryFee = round.treasuryFee + treasuryFee;
            prizePool = round.prizePool + prizeContribution;
          };
          roundRepo.save(updatedRound);

          let stats = statisticsRepo.get();
          statisticsRepo.set({
            stats with totalEntries = stats.totalEntries + 1;
          });

          Logger.event("entry_accepted", Principal.toText(caller));
          #ok(roundId);
        };
      };
    };
  };
};
