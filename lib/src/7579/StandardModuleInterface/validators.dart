part of 'interface.dart';

abstract class ValidatorModuleInterface extends Base7579ModuleInterface {
  ValidatorModuleInterface(super.wallet);

  final ContractAbi _abi = ContractAbi.fromJson(
    '[{"type":"function","name":"getValidatorsPaginated","inputs":[{"name":"cursor","type":"address","internalType":"address"},{"name":"pageSize","type":"uint256","internalType":"uint256"}],"outputs":[{"name":"array","type":"address[]","internalType":"address[]"},{"name":"next","type":"address","internalType":"address"}],"stateMutability":"view"}]',
    "getValidatorsPaginated",
  );

  // Encodes the validator's address as a 32-byte nonce key.
  ///
  /// Returns a [Uint8List] containing the validator's address padded to 32 bytes,
  /// which can be used as a unique nonce for validator operations.
  Uint8List encodeValidatorNonce() {
    return address.addressBytes.padRightTo32Bytes();
  }

  /// Sends Ether through the validator module using the validator's nonce key
  /// to ensure the validator is used for validating the user operation.
  ///
  /// Parameters:
  /// - [recipient]: The destination Ethereum address to send Ether to
  /// - [amount]: The amount of Ether to send
  ///
  /// Returns a [UserOperationResponse] representing the transaction status
  Future<UserOperationResponse> send(
    EthereumAddress recipient,
    EtherAmount amount,
  ) {
    return wallet.send(
      recipient,
      amount,
      nonceKey: Uint256.fromList(encodeValidatorNonce()),
    );
  }

  /// Sends a single transaction through the validator module
  /// uses the validator's nonce key for all transactions in the batch.
  /// this ensures that the Account impl switches to using the validator to validate user-operations.
  ///
  /// Parameters:
  /// - [to]: The destination Ethereum address
  /// - [encodedFunctionData]: The ABI-encoded function call data
  /// - [amount]: Optional amount of Ether to send with the transaction
  ///
  /// Returns a [UserOperationResponse] representing the transaction status
  Future<UserOperationResponse> sendTransaction(
    EthereumAddress to,
    Uint8List encodedFunctionData, {
    EtherAmount? amount,
  }) {
    return wallet.sendTransaction(
      to,
      encodedFunctionData,
      amount: amount,
      nonceKey: Uint256.fromList(encodeValidatorNonce()),
    );
  }

  /// Sends multiple transactions in a batch through the validator module
  /// uses the validator's nonce key for all transactions in the batch.
  /// this ensures that the Account impl switches to using the validator to validate user-operations.
  ///
  /// Parameters:
  /// - [recipients]: List of destination Ethereum addresses
  /// - [calls]: List of ABI-encoded function calls corresponding to each recipient
  /// - [amounts]: Optional list of Ether amounts to send with each transaction
  ///
  /// Returns a [UserOperationResponse] representing the batched transaction status
  Future<UserOperationResponse> sendBatchedTransaction(
    List<EthereumAddress> recipients,
    List<Uint8List> calls, {
    List<EtherAmount>? amounts,
  }) {
    return wallet.sendBatchedTransaction(
      recipients,
      calls,
      amounts: amounts,
      nonceKey: Uint256.fromList(encodeValidatorNonce()),
    );
  }

  Future<List<EthereumAddress>> getInstalledValidators() async {
    final result = await wallet.readContract(
      wallet.address,
      _abi,
      _abi.name,
      params: [SENTINEL_ADDRESS, BigInt.from(100)],
      sender: wallet.address,
    );
    final modules = List<EthereumAddress>.from(result.first);
    return modules;
  }

  Future<EthereumAddress> prevValidator() async {
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
}
