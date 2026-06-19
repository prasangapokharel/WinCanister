import Principal "mo:core/Principal";
import Result "mo:core/Result";
import ConfigRepository "../repositories/ConfigRepository";
import Config "../models/Config";
import Logger "../utils/Logger";

module {
  public class Service(configRepo : ConfigRepository.Repository) {
    public func getConfig() : Config.Config {
      configRepo.get();
    };

    public func getTreasuryPrincipal() : Principal {
      configRepo.get().treasuryPrincipal;
    };

    public func updateTreasury(caller : Principal, treasuryPrincipal : Principal) : Result.Result<Text, Text> {
      if (Principal.isAnonymous(caller)) {
        return #err("unauthorized");
      };
      let config = configRepo.get();
      if (not Principal.equal(caller, config.adminPrincipal)) {
        return #err("admin_only");
      };
      if (Principal.isAnonymous(treasuryPrincipal)) {
        return #err("invalid_treasury_principal");
      };
      configRepo.set({
        config with treasuryPrincipal = treasuryPrincipal;
      });
      Logger.event("treasury_updated", Principal.toText(treasuryPrincipal));
      #ok("treasury_updated");
    };
  };
};
