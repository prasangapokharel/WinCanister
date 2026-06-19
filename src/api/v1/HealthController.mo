import Text "mo:core/Text";

module {
  public type HealthResponse = {
    status : Text;
    version : Text;
  };

  public func health() : HealthResponse {
    { status = "healthy"; version = "1.0.0" };
  };
};
