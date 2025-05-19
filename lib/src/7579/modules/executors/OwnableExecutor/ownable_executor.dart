// ignore_for_file: public_member_api_docs, sort_constructors_first
part of '../../../../../modules.dart';

class OwnableExecutor extends ExecutorModuleInterface {
  static final _deployedModule = OwnableExecutorContract(getAddress());

  final EthereumAddress _initialOwner;

  OwnableExecutor(super.wallet, this._initialOwner);

  @override
  EthereumAddress get address => getAddress();

  @override
  Uint8List get initData => getInitData();

  @override
  String get name => 'OwnableExecutor';

  @override
  ModuleType get type => ModuleType.executor;

  @override
  String get version => '1.0.0';

  Future<UserOperationReceipt?> addOwner(EthereumAddress owner) async {
    final calldata = _deployedModule.contract.function('addOwner').encodeCall([
      owner,
    ]);
    final tx = await wallet.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  @override
  Uint8List getInitData() {
    return _initialOwner.addressBytes;
  }

  Future<List<EthereumAddress>?> getOwners([EthereumAddress? account]) async {
    final result = await wallet.readContract(
      address,
      ownable_executor_abi,
      'getOwners',
      params: [account ?? wallet.address],
    );
    return result.firstOrNull;
  }

  Future<BigInt?> ownerCount([EthereumAddress? account]) async {
    final result = await wallet.readContract(
      address,
      ownable_executor_abi,
      'ownerCount',
      params: [account ?? wallet.address],
    );
    return result.firstOrNull;
  }

  Future<UserOperationReceipt?> removeOwner(EthereumAddress owner) async {
    final oowners = await getOwners() ?? [];
    final currentOwnerIndex = oowners.indexOf(owner);

    EthereumAddress prevOwner;
    if (currentOwnerIndex == -1) {
      throw Exception('Owner not found');
    } else if (currentOwnerIndex == 0) {
      prevOwner = SENTINEL_ADDRESS;
    } else {
      prevOwner = oowners[currentOwnerIndex - 1];
    }
    final calldata = _deployedModule.contract
        .function('removeOwner')
        .encodeCall([prevOwner, owner]);
    final tx = await wallet.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  /// Executes multiple transactions on an owned account in a single batch i.e another modular smartwallet
  ///
  /// [ownedAccount] The smart wallet account to execute the transactions on
  /// [data] The batch transaction data to execute
  /// Returns a [UserOperationReceipt] if successful, null otherwise
  static Future<UserOperationReceipt?> executeBatchOnOwnedAccount(
    SmartWallet currentAccount,
    EthereumAddress ownedAccount,
    Uint8List data,
  ) async {
    final calldata = _deployedModule.contract
        .function('executeBatchOnOwnedAccount')
        .encodeCall([ownedAccount, data]);
    final tx = await currentAccount.sendTransaction(getAddress(), calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  /// Executes a single transaction on an owned account. i.e another modular smartwallet
  ///
  /// [ownedAccount] The smart wallet account to execute the transaction on
  /// [data] The transaction data to execute
  /// Returns a [UserOperationReceipt] if successful, null otherwise
  static Future<UserOperationReceipt?> executeOnOwnedAccount(
    SmartWallet currentAccount,
    EthereumAddress ownedAccount,
    Uint8List data,
  ) async {
    final calldata = _deployedModule.contract
        .function('executeOnOwnedAccount')
        .encodeCall([ownedAccount, data]);
    final tx = await currentAccount.sendTransaction(getAddress(), calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  // must be static
  static EthereumAddress getAddress() {
    return EthereumAddress.fromHex(
      '0x4Fd8d57b94966982B62e9588C27B4171B55E8354',
    );
  }
}
