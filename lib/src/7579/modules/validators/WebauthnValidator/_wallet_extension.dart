part of '../../../../../modules.dart';

class _WebauthnWalletExtension extends SmartWallet {
  final Set<PassKeyPair> _keyPairs;

  @protected
  final bool uvRequired;

  factory _WebauthnWalletExtension.fromWallet(
    SmartWallet wallet,
    Set<PassKeyPair> keyPairs, [
    PassKeySigner? signer,
    bool uvRequired = true,
  ]) {
    if (wallet is _WebauthnWalletExtension) {
      return wallet;
    }

    return _WebauthnWalletExtension.internal(
      wallet.state.copyWith(signer: signer),
      keyPairs,
      uvRequired,
    );
  }

  _WebauthnWalletExtension.internal(
    super._state,
    this._keyPairs,
    this.uvRequired,
  ) : assert(
        _state.signer is PassKeySigner,
        "[WebauthnValidator]: SmartWallet signer must be an instance of PasskeySigner",
      );

  @override
  String get dummySignature => _getDummySignature();

  Uint8List encodeSignatures(List<Uint8List> ids, List<PassKeySignature> sigs) {
    return abi.encode(
      ["bytes32[]", "bool", "(bytes,string,uint256,uint256,uint256,uint256)[]"],
      [
        ids,
        true, // usePrecompile is always true
        [
          ...sigs.map(
            (sig) => [
              sig.authData,
              sig.clientDataJSON,
              BigInt.from(sig.challengePos - 13), // `"challenge":"`
              BigInt.from(sig.typePos - 8), // `"type":"`
              sig.signature.$1.value,
              sig.signature.$2.value,
            ],
          ),
        ],
      ],
    );
  }

  /// {@macro genSig}
  Future<(List<Uint8List>, List<PassKeySignature>)> generateOffchainSignature(
    UserOperation op, [
    BlockInfo? blockInfo,
  ]) async {
    final signer = state.signer as PassKeySigner;
    final hash = op.hash(chain);

    List<Uint8List> credIds = [];
    List<PassKeySignature> sigs = [];

    for (var keypair in _keyPairs) {
      final credId = _getCredentialId(keypair);
      credIds.add(credId);

      final sig = await signer.signToPasskeySignature(
        hash,
        knownCredentials: [
          signer.credentialIdToType(keypair.authData.rawCredential),
        ],
      );
      sigs.add(sig);
    }
    return (credIds, sigs);
  }

  @override
  Future<String> generateSignature(
    UserOperation op,
    dynamic blockInfo,
    int? _,
  ) async {
    final base = await generateOffchainSignature(op, blockInfo);

    final webauthnSignature = encodeSignatures(base.$1, base.$2);
    return hexlify(webauthnSignature);
  }

  Uint8List _getCredentialId(PassKeyPair keypair) {
    return keccak256(
      abi.encode(
        ["uint256", "uint256", "bool", "address"],
        [
          keypair.authData.publicKey.$1.value,
          keypair.authData.publicKey.$2.value,
          uvRequired,
          address,
        ],
      ),
    );
  }

  String _getDummySignature() {
    final uv = uvRequired ? 0x04 : 0x01;
    final challenge = "p5aV2uHXr0AOqUk7HQitvi-Ny1p5aV2uHXr0AOqUk7H";
    final dummyCdField =
        '{"type":"webauthn.get","challenge":$challenge,"origin":"https://variance.space"}';
    final dummyAdField = Uint8List(37);
    dummyAdField.fillRange(0, dummyAdField.length, 0xfe);
    dummyAdField[32] = uv;

    final credId = _getCredentialId(_keyPairs.first);
    final sig = PassKeySignature(
      "null",
      credId,
      (Uint256.fromHex("0x${'ec' * 32}"), Uint256.fromHex("0x${'d5a' * 21}f")),
      dummyAdField,
      dummyCdField,
      dummyCdField.indexOf(challenge),
      dummyCdField.indexOf('webauthn.get'),
      "null",
    );

    final webauthnSignature = encodeSignatures([credId], [sig]);
    return hexlify(webauthnSignature);
  }

  @override
  Future<UserOperation> prepareUserOperation(
    UserOperation op, {
    Uint256? nonceKey,
  }) {
    final validatorNonceKey = Uint256.fromList(
      WebauthnValidator.getAddress().value.padToNBytes(24, direction: "right"),
    );
    return super.prepareUserOperation(op, nonceKey: validatorNonceKey);
  }
}
