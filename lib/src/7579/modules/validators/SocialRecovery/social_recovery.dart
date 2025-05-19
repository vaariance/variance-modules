part of '../../../../../modules.dart';

class SocialRecovery extends ValidatorModuleInterface {
  static final _deployedModule = SocialRecoveryContract(getAddress());

  final BigInt _initThreshold;

  final List<EthereumAddress> _initGuardians;

  SocialRecovery(super.wallet, this._initThreshold, this._initGuardians)
    : assert(
        _initThreshold > BigInt.zero,
        ModuleVariablesNotSetError('SocialRecoveryValidator', 'threshold'),
      ),
      assert(
        _initGuardians.length >= _initThreshold.toInt(),
        ModuleVariablesNotSetError('SocialRecoveryValidator', 'guardians'),
      ) {
    _initGuardians.sort((a, b) => a.hex.compareTo(b.hex));
  }

  @override
  EthereumAddress get address => getAddress();

  @override
  Uint8List get initData => getInitData();

  @override
  String get name => "SocialRecoveryValidator";

  @override
  ModuleType get type => ModuleType.validator;

  @override
  String get version => "1.0.0";

  Future<UserOperationReceipt?> addGuardian(EthereumAddress guardian) async {
    final calldata = _deployedModule.contract
        .function('addGuardian')
        .encodeCall([guardian]);
    final tx = await wallet.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<List<EthereumAddress>?> getGuardians([
    EthereumAddress? account,
  ]) async {
    final result = await wallet.readContract(
      address,
      social_recovery_abi,
      'getGuardians',
      params: [account ?? wallet.address],
    );
    return result.firstOrNull;
  }

  @override
  Uint8List getInitData() {
    return abi.encode(
      ["uint256", "address[]"],
      [_initThreshold, _initGuardians],
    );
  }

  Future<BigInt?> guardianCount([EthereumAddress? account]) async {
    final result = await wallet.readContract(
      address,
      social_recovery_abi,
      'guardianCount',
      params: [account ?? wallet.address],
    );
    return result.firstOrNull;
  }

  Future<UserOperationReceipt?> removeGuardian(EthereumAddress guardian) async {
    final guardians = await getGuardians() ?? [];
    final currentGuardianIndex = guardians.indexOf(guardian);

    EthereumAddress prevGuardian;
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
    final tx = await wallet.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> setThreshold(int threshold) async {
    final calldata = _deployedModule.contract
        .function('setThreshold')
        .encodeCall([BigInt.from(threshold)]);
    final tx = await wallet.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<BigInt?> threshold([EthereumAddress? account]) async {
    final result = await wallet.readContract(
      address,
      social_recovery_abi,
      'threshold',
      params: [account ?? wallet.address],
    );
    return result.firstOrNull;
  }

  // must be static
  static EthereumAddress getAddress() {
    return EthereumAddress.fromHex(
      '0xA04D053b3C8021e8D5bF641816c42dAA75D8b597',
    );
  }
}
