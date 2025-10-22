abstract class WalletEvent {
  const WalletEvent();
}

class WalletStarted extends WalletEvent {
  const WalletStarted();
}

class WalletRefreshRequested extends WalletEvent {
  const WalletRefreshRequested();
}
