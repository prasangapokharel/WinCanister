import Principal "mo:core/Principal";

module {
  public func validateAuthenticated(caller : Principal) : ?Text {
    if (Principal.isAnonymous(caller)) {
      ?"unauthorized";
    } else {
      null;
    };
  };
};
