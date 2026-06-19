module {
  public type ErrorResponse = {
    code : Text;
    message : Text;
  };

  public func create(code : Text, message : Text) : ErrorResponse {
    { code = code; message = message };
  };
};
