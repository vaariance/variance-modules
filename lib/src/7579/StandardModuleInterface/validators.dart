part of 'interface.dart';

abstract class ValidatorModuleInterface extends Base7579ModuleInterface {
  ValidatorModuleInterface(super.wallet);

  // Encodes the validator's address as a 32-byte nonce key.
  ///
  /// Returns a [Uint8List] containing the validator's address padded to 32 bytes,
  /// which can be used as a unique nonce for validator operations.
  Uint8List encodeValidatorNonce() {
    return address.addressBytes.padRightTo32Bytes();
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
      EthereumAddress to, Uint8List encodedFunctionData,
      {EtherAmount? amount}) {
    return wallet.sendTransaction(to, encodedFunctionData,
        amount: amount, nonceKey: Uint256.fromList(encodeValidatorNonce()));
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
    return wallet.sendBatchedTransaction(recipients, calls,
        amounts: amounts, nonceKey: Uint256.fromList(encodeValidatorNonce()));
  }
}
