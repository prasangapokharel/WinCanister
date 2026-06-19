import Time "mo:core/Time";

module {
  public func now() : Int {
    Time.now();
  };

  public func hasElapsed(startTime : Int, durationNs : Int) : Bool {
    now() >= startTime + durationNs;
  };

  public func endTime(startTime : Int, durationNs : Int) : Int {
    startTime + durationNs;
  };
};
