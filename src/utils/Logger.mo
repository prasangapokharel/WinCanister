import Debug "mo:core/Debug";

module {
  public func info(message : Text) {
    Debug.print("[INFO] " # message);
  };

  public func error(message : Text) {
    Debug.print("[ERROR] " # message);
  };

  public func event(name : Text, detail : Text) {
    Debug.print("[EVENT] " # name # ": " # detail);
  };
};
