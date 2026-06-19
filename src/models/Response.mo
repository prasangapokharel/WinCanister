import Result "mo:core/Result";

module {
  public type SuccessResponse = {
    message : Text;
  };

  public type ErrorResponse = {
    code : Text;
    message : Text;
  };

  public func toError(message : Text) : ErrorResponse {
    { code = "error"; message = message };
  };

  public func toSuccess(message : Text) : SuccessResponse {
    { message = message };
  };

  public type ApiResult<T> = Result.Result<T, Text>;
};
