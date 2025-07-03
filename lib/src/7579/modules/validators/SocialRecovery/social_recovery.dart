part of '../../../../../modules.dart';

class SocialRecovery extends ValidatorModuleInterface {
  static final _deployedModule = SocialRecoveryContract(getAddress());

  final BigInt _initThreshold;

  final List<Address> _initGuardians;

  SocialRecovery(
    SmartWallet wallet,
    this._initThreshold,
    this._initGuardians, {
    MSI? guardianSigner,
  }) : assert(
         _initThreshold > BigInt.zero,
         ModuleVariableError('SocialRecoveryValidator', 'threshold'),
       ),
       assert(
         _initGuardians.length >= _initThreshold.toInt(),
         ModuleVariableError('SocialRecoveryValidator', 'guardians'),
       ),
       super(
         _SocialRecoveryWalletExtension.fromWallet(wallet, guardianSigner),
       ) {
    _initGuardians.sort((a, b) => a.with0x.compareTo(b.with0x));
  }

  ///////////////////////////////////////////////////////////////
  //            GETTERS
  ///////////////////////////////////////////////////////////////
  @override
  Address get address => getAddress();

  @override
  Uint8List get initData => getInitData();

  @override
  String get name => "SocialRecoveryValidator";

  @override
  ModuleType get type => ModuleType.validator;

  @override
  String get version => "1.0.0";

  ///////////////////////////////////////////////////////////////
  //            READS
  ///////////////////////////////////////////////////////////////
  @override
  Uint8List getInitData() {
    return abi.encode(
      ["uint256", "address[]"],
      [_initThreshold, _initGuardians],
    );
  }

  Future<List<Address>?> getGuardians([Address? account]) async {
    final result = await contract.readContract(
      address,
      social_recovery_abi,
      'getGuardians',
      params: [account ?? contract.address],
    );
    return result.firstOrNull;
  }

  Future<BigInt?> guardianCount([Address? account]) async {
    final result = await contract.readContract(
      address,
      social_recovery_abi,
      'guardianCount',
      params: [account ?? contract.address],
    );
    return result.firstOrNull;
  }

  Future<BigInt?> threshold([Address? account]) async {
    final result = await contract.readContract(
      address,
      social_recovery_abi,
      'threshold',
      params: [account ?? contract.address],
    );
    return result.firstOrNull;
  }

  //////////////////////////////////////////////////////////////////
  //            RECOVERY
  ///////////////////////////////////////////////////////////////
  ///

  /// {@macro getOp}
  Future<UserOperation> getRecoveryOperation(
    List<(RecoveryMechanism, RecoveryData)> recovery,
  ) async {
    final account = (contract as _SocialRecoveryWalletExtension);
    final thd = await threshold();
    account.threshold = thd;
    return account.getRecoveryOperation(recovery);
  }

  /// {@macro genSig}
  Future<(List<Uint8List>?, List)> generateOffchainSignature(
    UserOperation op, [
    BlockInfo? blockInfo,
  ]) async {
    return (contract as _SocialRecoveryWalletExtension)
        .generateOffchainSignature(op, blockInfo);
  }

  /// {@macro execRecovery}
  Future<UserOperationResponse> executeRecovery(
    UserOperation signedOp,
    List<Uint8List> signatures,
  ) async {
    return (contract as _SocialRecoveryWalletExtension).executeRecovery(
      signedOp,
      signatures,
    );
  }

  //////////////////////////////////////////////////////////////////
  //            WRITES
  ///////////////////////////////////////////////////////////////
  Future<UserOperationReceipt?> addGuardian(
    Address guardian, [
    SmartContract? service,
  ]) async {
    final calldata = _deployedModule.contract
        .function('addGuardian')
        .encodeCall([guardian]);
    final tx = await (service ?? contract).sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> removeGuardian(
    Address guardian, [
    SmartContract? service,
  ]) async {
    final guardians = await getGuardians() ?? [];
    final currentGuardianIndex = guardians.indexOf(guardian);

    Address prevGuardian;
    if (currentGuardianIndex == -1) {
      throw Exception('Guardian not found');
    } else if (currentGuardianIndex == 0) {
      prevGuardian = SENTINEL_ADDRESS;
    } else {
      prevGuardian = guardians[currentGuardianIndex - 1];
    }
    final calldata = _deployedModule.contract
        .function('removeGuardian')
        .encodeCall([prevGuardian, guardian]);
    final tx = await (service ?? contract).sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> setThreshold(
    int threshold, [
    SmartContract? service,
  ]) async {
    final calldata = _deployedModule.contract
        .function('setThreshold')
        .encodeCall([BigInt.from(threshold)]);
    final tx = await (service ?? contract).sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  @override
  Future<UserOperationResponse> proxyTransaction(
    List<Address> recipients,
    List<Uint8List> calls, {
    List<BigInt>? amountsInWei,
  }) {
    return (contract as _SocialRecoveryWalletExtension).sendBatchedTransaction(
      recipients,
      calls,
      amountsInWei: amountsInWei,
    );
  }

  //////////////////////////////////////////////////////////////////
  //            STATIC METHODS
  ///////////////////////////////////////////////////////////////
  static Address getAddress() {
    return Address.fromHex('0xA04D053b3C8021e8D5bF641816c42dAA75D8b597');
  }
}
