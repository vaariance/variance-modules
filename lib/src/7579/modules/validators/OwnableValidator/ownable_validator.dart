part of '../../../../../modules.dart';

class OwnableValidator extends ValidatorModuleInterface {
  static final _deployedModule = OwnableValidatorContract(getAddress());

  final BigInt _initThreshold;

  final List<EthereumAddress> _initOwners;

  OwnableValidator(super.wallet, this._initThreshold, this._initOwners)
    : assert(
        _initThreshold > BigInt.zero,
        ModuleVariablesNotSetError('OwnableValidator', 'threshold'),
      ),
      assert(
        _initOwners.length >= _initThreshold.toInt(),
        ModuleVariablesNotSetError('OwnableValidator', 'owners'),
      ) {
    _initOwners.sort((a, b) => a.hex.compareTo(b.hex));
  }

  @override
  EthereumAddress get address => getAddress();

  @override
  Uint8List get initData => getInitData();

  @override
  String get name => "OwnableValidator";

  @override
  ModuleType get type => ModuleType.validator;

  @override
  String get version => "1.0.0";

  Future<UserOperationReceipt?> addOwner(EthereumAddress owner) async {
    final owners = await getOwners() ?? [];
    final currentOwnerIndex = owners.indexOf(owner);

    if (currentOwnerIndex != -1) {
      throw Exception('Owner already exists');
    }

    final calldata = _deployedModule.contract.function('addOwner').encodeCall([
      owner,
    ]);
    final tx = await wallet.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  @override
  Uint8List getInitData() {
    return abi.encode(["uint256", "address[]"], [_initThreshold, _initOwners]);
  }

  Future<List<EthereumAddress>?> getOwners([EthereumAddress? account]) async {
    final result = await wallet.readContract(
      address,
      ownable_validator_abi,
      'getOwners',
      params: [account ?? wallet.address],
    );
    return result.firstOrNull;
  }

  Future<BigInt?> ownerCount([EthereumAddress? account]) async {
    final result = await wallet.readContract(
      address,
      ownable_validator_abi,
      'ownerCount',
      params: [account ?? wallet.address],
    );
    return result.firstOrNull;
  }

  Future<UserOperationReceipt?> removeOwner(EthereumAddress owner) async {
    final owners = await getOwners() ?? [];
    final currentOwnerIndex = owners.indexOf(owner);

    EthereumAddress prevOwner;
    if (currentOwnerIndex == -1) {
      throw Exception('Owner not found');
    } else if (currentOwnerIndex == 0) {
      prevOwner = SENTINEL_ADDRESS;
    } else {
      prevOwner = owners[currentOwnerIndex - 1];
    }
    final calldata = _deployedModule.contract
        .function('removeOwner')
        .encodeCall([prevOwner, owner]);
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
      ownable_validator_abi,
      'threshold',
      params: [account ?? wallet.address],
    );
    return result.firstOrNull;
  }

  Future<bool> validateSignatureWithData(
    Uint8List hash,
    Uint8List signature,
    Uint8List data,
  ) async {
    final result = await wallet.readContract(
      address,
      ownable_validator_abi,
      'validateSignatureWithData',
      params: [hash, signature, data],
    );
    return result.first;
  }

  static Uint8List encodeValidationData(
    int threshold,
    List<EthereumAddress> owners,
  ) {
    owners.sort((a, b) => a.hex.compareTo(b.hex));
    return abi.encode(
      ["uint256", "address[]"],
      [BigInt.from(threshold), owners],
    );
  }

  // must be static
  static EthereumAddress getAddress() {
    return EthereumAddress.fromHex(
      '0x2483DA3A338895199E5e538530213157e931Bf06',
    );
  }

  static Uint8List getMockSignature(int threshold) {
    final mock = hexToBytes(
      "0xe8b94748580ca0b4993c9a1b86b5be851bfc076ff5ce3a1ff65bf16392acfcb800f9b4f1aef1555c7fce5599fffb17e7c635502154a0333ba21f3ae491839af51c",
    );
    return getOwnableValidatorSignature(List.filled(threshold, mock));
  }

  static Uint8List getOwnableValidatorSignature(List<Uint8List> signatures) {
    Uint8List signature = signatures.first;
    for (int i = 1; i < signatures.length; i++) {
      signature = signature.concat(signatures[i]);
    }
    return signature;
  }
}
