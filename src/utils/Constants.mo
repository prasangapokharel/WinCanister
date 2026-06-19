import AppConfig "../config/AppConfig";

module {
  public let MIN_ENTRY_ICP = AppConfig.MIN_ENTRY_AMOUNT;
  public let TREASURY_FEE_PERCENT = 1;
  public let PRIZE_POOL_PERCENT = 99;
  public let FIRST_PLACE_PERCENT = 60;
  public let SECOND_PLACE_PERCENT = 25;
  public let THIRD_PLACE_PERCENT = 15;
  public let MAX_WINNERS = AppConfig.MAX_WINNERS;
  public let ROUND_DURATION_HOURS = 24;
};
