part of '../../../../../modules.dart';

typedef RecoveryData = Uint8List;

enum RecoveryMechanism { setThreshold, addOwner }

class _SocialRecoveryWalletExtension extends SmartWallet {
  /// The threshold value for social recovery.
  ///
  /// This value determines the minimum number of guardians required for a recovery action.
  int _threshold = 0;

  factory _SocialRecoveryWalletExtension.fromWallet(
    SmartWallet wallet, [
    MSI? signer,
  ]) {
    if (wallet is _SocialRecoveryWalletExtension) {
      return wallet;
    }

    return _SocialRecoveryWalletExtension.internal(
      wallet.state.copyWith(signer: signer),
    );
  }

  _SocialRecoveryWalletExtension.internal(super._state)
    : assert(
        !(_state.signer is! PassKeySigner),
        "[SocialRecovery]: Social recovery is not enabled for passkey signers yet!",
      );

  set threshold(BigInt? value) => _threshold = value?.toInt() ?? 0;

  @override
  String get dummySignature =>
      hexlify(OwnableValidator.getMockSignature(_threshold));

  /// {@template execRecovery}
  /// Executes a social recovery operation using the provided signed user operation and guardian signatures
  ///
  /// This method:
  /// 1. Verifies that the OwnableValidator module is installed
  /// 2. Combines the guardian signatures into a single validator signature
  /// 3. Sends the signed user operation for execution
  ///
  /// @param signedOp The user operation to execute, must contain recovery calldata
  /// @param signatures List of guardian signatures authorizing the recovery
  /// @return [Future<UserOperationResponse>] containing the transaction response
  /// {@endtemplate}
  Future<UserOperationResponse> executeRecovery(
    UserOperation signedOp,
    List<Uint8List> signatures,
  ) async {
    final isOwnableValidatorInstalled = await isModuleInstalled(
      ModuleType.validator,
      OwnableValidator.getAddress(),
    );
    require(
      isOwnableValidatorInstalled ?? false,
      "OwnableValidator is not installed: it is required for SocialRecovery",
    );
    signedOp.signature = hexlify(
      OwnableValidator.getOwnableValidatorSignature(signatures),
    );
    return sendSignedUserOperation(signedOp);
  }

  /// {@template genSig}
  /// Generates signatures for a UserOperation without broadcasting it onchain.
  ///
  /// This function creates the necessary signatures for a UserOperation to be valid,
  /// but does not submit the operation to the blockchain. Useful for
  /// preparing operations for later use.
  ///
  /// Returns a tuple containing:
  /// - [List<Uint8List>?]: Optional accompanying data
  /// - [List<dynamic>]: The Actual signatures in expected types
  /// {@endtemplate}
  Future<(List<Uint8List>?, List<Uint8List>)> generateOffchainSignature(
    UserOperation op, [
    BlockInfo? blockInfo,
  ]) async {
    final hash = op.hash(chain);
    final sig = await state.signer.personalSign(hash);
    return (null, [sig]);
  }

  /// {@template getOp}
  /// Creates a user operation for social recovery actions
  ///
  /// Takes a list of recovery actions to perform, where each action is a tuple of:
  /// - [RecoveryMechanism]: The type of recovery action (setThreshold or addOwner)
  /// - [RecoveryData]: The data needed for that action (threshold value or owner address)
  ///
  /// The method will:
  /// 1. Validate the recovery list is not empty
  /// 2. Generate calldata for each recovery action
  /// 3. Batch the calls together into a single user operation
  /// 4. Add a mock signature, gas estimation and sponsorship
  ///
  /// Example Usage flow:
  /// - Affected user calls this function with the recovery actions they want to perform.
  /// - Sends the returned `UserOperation` to user's guardians
  /// - Guardians sign the user operation using `generateOffchainSignature`
  /// - Affected user calls `executeRecovery` with the signed user operation and signatures
  ///
  /// @param recovery List of recovery actions to perform
  /// @return [Future<UserOperation>] The prepared user operation ready for guardian signatures
  /// {@endtemplate}
  Future<UserOperation> getRecoveryOperation(
    List<(RecoveryMechanism, RecoveryData)> recovery,
  ) async {
    require(_threshold != 0, 'Threshold must be set');
    require(recovery.isNotEmpty, 'Recovery list is empty');
    getCalls() {
      final calls = List.filled(recovery.length, Uint8List(0));
      for (var i in recovery) {
        calls[recovery.indexOf(i)] = switch (i.$1) {
          RecoveryMechanism.setThreshold => OwnableValidator
              ._deployedModule
              .contract
              .function('setThreshold')
              .encodeCall([bytesToInt(i.$2)]),
          RecoveryMechanism.addOwner => OwnableValidator
              ._deployedModule
              .contract
              .function('addOwner')
              .encodeCall([Address(i.$2)]),
        };
      }
    }

    final calldata = await get7579ExecuteBatchCalldata(
      recipients: List.filled(recovery.length, OwnableValidator.getAddress()),
      innerCalls: getCalls(),
    );

    return prepareUserOperation(
      buildUserOperation(callData: calldata),
    ).then(overrideGas).then(sponsorUserOperation);
  }

  @override
  Future<UserOperation> prepareUserOperation(
    UserOperation op, {
    Uint256? nonceKey,
  }) {
    final validatorNonceKey = Uint256.fromList(
      SocialRecovery.getAddress().value.padToNBytes(24, direction: "right"),
    );
    return super.prepareUserOperation(op, nonceKey: validatorNonceKey);
  }
}
