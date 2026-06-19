import Principal "mo:core/Principal";
import WalletConfig "../config/WalletConfig";

module {
  public type Config = {
    treasuryPrincipal : Principal;
    adminPrincipal : Principal;
  };

  public func defaultConfig() : Config {
    {
      treasuryPrincipal = Principal.fromText(WalletConfig.TREASURY_PRINCIPAL_TEXT);
      adminPrincipal = Principal.fromText(WalletConfig.ADMIN_PRINCIPAL_TEXT);
    };
  };
};
