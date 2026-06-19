import Result "mo:core/Result";

module {
  public type ApiResult<T> = Result.Result<T, Text>;
};
