import RawRandom "../randomness/RawRandom";

module {
  public class Service(provider : RawRandom.RandomProvider) {
    public func getRandomBytes() : async RawRandom.RandomResult {
      await RawRandom.fetchRandom(provider);
    };
  };
};
