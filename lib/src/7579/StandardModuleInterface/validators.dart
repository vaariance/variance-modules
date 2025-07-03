part of 'interface.dart';

abstract class ValidatorModuleInterface extends Base7579ModuleInterface {
  ValidatorModuleInterface(super._wallet);

  final ContractAbi _abi = ContractAbi.fromJson(
    '[{"type":"function","name":"getValidatorsPaginated","inputs":[{"name":"cursor","type":"address","internalType":"address"},{"name":"pageSize","type":"uint256","internalType":"uint256"}],"outputs":[{"name":"array","type":"address[]","internalType":"address[]"},{"name":"next","type":"address","internalType":"address"}],"stateMutability":"view"}]',
    "getValidatorsPaginated",
  );

  // Encodes the validator's address as a 32-byte nonce key.
  ///
  /// Returns a [Uint256] containing the validator's address padded to 32 bytes,
  /// which can be used as a unique nonce for validator operations.
  Uint256 get validatorNonceKey =>
      Uint256.fromList(address.value.padToNBytes(24, direction: "right"));

  Future<List<Address>> getInstalledValidators() async {
    final result = await _wallet.readContract(
      _wallet.address,
      _abi,
      _abi.name,
      params: [SENTINEL_ADDRESS, BigInt.from(100)],
      sender: _wallet.address,
    );
    final modules = List<Address>.from(result.first);
    return modules;
  }

  Future<Address> prevValidator() async {
    final validators = await getInstalledValidators();
    final index = validators.indexOf(address);
    if (index == 0) {
      return SENTINEL_ADDRESS;
    } else if (index > 0) {
      return validators[index - 1];
    } else {
      throw Exception('Validator not found');
    }
  }

  @override
  Future<Uint8List> getDeInitData([Uint8List? context]) async {
    final prev = await prevValidator();
    return abi.encode(["address", "bytes"], [prev, context ?? Uint8List(0)]);
  }

  /// {@macro txTemplate}
  Future<UserOperationResponse> proxyTransaction(
    List<Address> recipients,
    List<Uint8List> calls, {
    List<BigInt>? amountsInWei,
  });
}
