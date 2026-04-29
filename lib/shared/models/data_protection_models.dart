class DataProtectionState {
  const DataProtectionState({
    required this.ready,
    required this.usingEncryptedStorage,
    required this.showUpgradeExplainer,
    required this.statusMessage,
    this.errorMessage,
  });

  const DataProtectionState.ready({
    bool showUpgradeExplainer = false,
    String statusMessage = 'Local encryption active',
  }) : this(
         ready: true,
         usingEncryptedStorage: true,
         showUpgradeExplainer: showUpgradeExplainer,
         statusMessage: statusMessage,
       );

  const DataProtectionState.failed(String message)
    : this(
        ready: false,
        usingEncryptedStorage: false,
        showUpgradeExplainer: false,
        statusMessage: 'Local protection failed',
        errorMessage: message,
      );

  final bool ready;
  final bool usingEncryptedStorage;
  final bool showUpgradeExplainer;
  final String statusMessage;
  final String? errorMessage;
}
