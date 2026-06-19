import StableRoundStore "StableRoundStore";
import StableEntryStore "StableEntryStore";
import StableWinnerStore "StableWinnerStore";
import StableTreasuryStore "StableTreasuryStore";
import StableStatisticsStore "StableStatisticsStore";
import StableConfigStore "StableConfigStore";
import StablePayoutStore "StablePayoutStore";
import StableProcessedDepositStore "StableProcessedDepositStore";
import StableAddressEntryStore "StableAddressEntryStore";

module {
  public type StableData = {
    rounds : StableRoundStore.StableData;
    entries : StableEntryStore.StableData;
    winners : StableWinnerStore.StableData;
    treasury : StableTreasuryStore.StableData;
    statistics : StableStatisticsStore.StableData;
    config : StableConfigStore.StableData;
    payouts : StablePayoutStore.StableData;
    processedDeposits : StableProcessedDepositStore.StableData;
    addressEntries : StableAddressEntryStore.StableData;
  };

  public type StorePreDeposits = {
    rounds : StableRoundStore.Store;
    entries : StableEntryStore.Store;
    winners : StableWinnerStore.Store;
    treasury : StableTreasuryStore.Store;
    statistics : StableStatisticsStore.Store;
    config : StableConfigStore.Store;
    payouts : StablePayoutStore.Store;
  };

  public type StoreWithProcessedDeposits = {
    rounds : StableRoundStore.Store;
    entries : StableEntryStore.Store;
    winners : StableWinnerStore.Store;
    treasury : StableTreasuryStore.Store;
    statistics : StableStatisticsStore.Store;
    config : StableConfigStore.Store;
    payouts : StablePayoutStore.Store;
    processedDeposits : StableProcessedDepositStore.Store;
  };

  public type Store = {
    rounds : StableRoundStore.Store;
    entries : StableEntryStore.Store;
    winners : StableWinnerStore.Store;
    treasury : StableTreasuryStore.Store;
    statistics : StableStatisticsStore.Store;
    config : StableConfigStore.Store;
    payouts : StablePayoutStore.Store;
    processedDeposits : StableProcessedDepositStore.Store;
    addressEntries : StableAddressEntryStore.Store;
  };

  public func emptyPreDeposits() : StorePreDeposits {
    {
      rounds = StableRoundStore.empty();
      entries = StableEntryStore.empty();
      winners = StableWinnerStore.empty();
      treasury = StableTreasuryStore.empty();
      statistics = StableStatisticsStore.empty();
      config = StableConfigStore.empty();
      payouts = StablePayoutStore.empty();
    };
  };

  public func empty() : Store {
    {
      rounds = StableRoundStore.empty();
      entries = StableEntryStore.empty();
      winners = StableWinnerStore.empty();
      treasury = StableTreasuryStore.empty();
      statistics = StableStatisticsStore.empty();
      config = StableConfigStore.empty();
      payouts = StablePayoutStore.empty();
      processedDeposits = StableProcessedDepositStore.empty();
      addressEntries = StableAddressEntryStore.empty();
    };
  };

  public func toStable(store : Store) : StableData {
    {
      rounds = StableRoundStore.toStable(store.rounds);
      entries = StableEntryStore.toStable(store.entries);
      winners = StableWinnerStore.toStable(store.winners);
      treasury = StableTreasuryStore.toStable(store.treasury);
      statistics = StableStatisticsStore.toStable(store.statistics);
      config = StableConfigStore.toStable(store.config);
      payouts = StablePayoutStore.toStable(store.payouts);
      processedDeposits = StableProcessedDepositStore.toStable(store.processedDeposits);
      addressEntries = StableAddressEntryStore.toStable(store.addressEntries);
    };
  };

  public func fromStable(data : StableData) : Store {
    {
      rounds = StableRoundStore.fromStable(data.rounds);
      entries = StableEntryStore.fromStable(data.entries);
      winners = StableWinnerStore.fromStable(data.winners);
      treasury = StableTreasuryStore.fromStable(data.treasury);
      statistics = StableStatisticsStore.fromStable(data.statistics);
      config = StableConfigStore.fromStable(data.config);
      payouts = StablePayoutStore.fromStable(data.payouts);
      processedDeposits = StableProcessedDepositStore.fromStable(data.processedDeposits);
      addressEntries = StableAddressEntryStore.fromStable(data.addressEntries);
    };
  };
};
