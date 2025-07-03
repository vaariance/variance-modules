part of '../../../../../modules.dart';

class OwnableValidator extends ValidatorModuleInterface {
  static final _deployedModule = OwnableValidatorContract(getAddress());

  final BigInt _initThreshold;

  final List<Address> _initOwners;

  OwnableValidator(super.wallet, this._initThreshold, this._initOwners)
    : assert(
        _initThreshold > BigInt.zero,
        ModuleVariableError('OwnableValidator', 'threshold'),
      ),
      assert(
        _initOwners.length >= _initThreshold.toInt(),
        ModuleVariableError('OwnableValidator', 'owners'),
      ) {
    _initOwners.sort((a, b) => a.with0x.compareTo(b.with0x));
  }

  ///////////////////////////////////////////////////////////////
  //            GETTERS
  ///////////////////////////////////////////////////////////////
  @override
  Address get address => getAddress();

  @override
  Uint8List get initData => getInitData();

  @override
  String get name => "OwnableValidator";

  @override
  ModuleType get type => ModuleType.validator;

  @override
  String get version => "1.0.0";

  ///////////////////////////////////////////////////////////////
  //            READS
  ///////////////////////////////////////////////////////////////
  @override
  Uint8List getInitData() {
    return abi.encode(["uint256", "address[]"], [_initThreshold, _initOwners]);
  }

  Future<List<Address>?> getOwners([Address? account]) async {
    final result = await contract.readContract(
      address,
      ownable_validator_abi,
      'getOwners',
      params: [account ?? contract.address],
    );
    return result.firstOrNull;
  }

  Future<BigInt?> ownerCount([Address? account]) async {
    final result = await contract.readContract(
      address,
      ownable_validator_abi,
      'ownerCount',
      params: [account ?? contract.address],
    );
    return result.firstOrNull;
  }

  Future<BigInt?> threshold([Address? account]) async {
    final result = await contract.readContract(
      address,
      ownable_validator_abi,
      'threshold',
      params: [account ?? contract.address],
    );
    return result.firstOrNull;
  }

  Future<bool> validateSignatureWithData(
    Uint8List hash,
    Uint8List signature,
    Uint8List data,
  ) async {
    final result = await contract.readContract(
      address,
      ownable_validator_abi,
      'validateSignatureWithData',
      params: [hash, signature, data],
    );
    return result.first;
  }

  //////////////////////////////////////////////////////////////////
  //            WRITES
  ///////////////////////////////////////////////////////////////
  Future<UserOperationReceipt?> addOwner(
    Address owner, [
    SmartContract? service,
  ]) async {
    final owners = await getOwners() ?? [];
    final currentOwnerIndex = owners.indexOf(owner);

    if (currentOwnerIndex != -1) {
      throw Exception('Owner already exists');
    }

    final calldata = _deployedModule.contract.function('addOwner').encodeCall([
      owner,
    ]);
    final tx = await (service ?? contract).sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> removeOwner(
    Address owner, [
    SmartContract? service,
  ]) async {
    final owners = await getOwners() ?? [];
    final currentOwnerIndex = owners.indexOf(owner);

    Address prevOwner;
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
    return (contract as SmartWallet).sendBatchedTransaction(
      recipients,
      calls,
      amountsInWei: amountsInWei,
    );
  }

  //////////////////////////////////////////////////////////////////
  //            STATIC METHODS
  ///////////////////////////////////////////////////////////////
  static Uint8List encodeValidationData(int threshold, List<Address> owners) {
    owners.sort((a, b) => a.with0x.compareTo(b.with0x));
    return abi.encode(
      ["uint256", "address[]"],
      [BigInt.from(threshold), owners],
    );
  }

  static Address getAddress() {
    return Address.fromHex('0x2483DA3A338895199E5e538530213157e931Bf06');
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
