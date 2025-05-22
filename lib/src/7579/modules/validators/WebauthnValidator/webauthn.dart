part of '../../../../../modules.dart';

class WebauthnValidator extends ValidatorModuleInterface {
  static final _deployedModule = WebauthnContract(getAddress());

  final BigInt _initThreshold;

  final PassKeyPair _keyPair;

  WebauthnValidator(
    SmartWallet wallet,
    this._initThreshold,
    this._keyPair, {
    PassKeySigner? signer,
    bool uvRequired = true,
  }) : assert(
         _initThreshold == BigInt.one,
         ModuleVariablesNotSetError('WebAuthnValidator', 'threshold'),
       ),
       super(
         _WebauthnExtendedWallet.fromWallet(
           wallet,
           _keyPair,
           signer,
           uvRequired,
         ),
       );

  @override
  EthereumAddress get address => getAddress();

  @override
  Uint8List get initData => getInitData();

  @override
  String get name => "WebAuthnValidator";

  @override
  ModuleType get type => ModuleType.validator;

  @override
  String get version => "1.0.0";

  Future<UserOperationReceipt?> addCredential(PassKeyPair keypair) async {
    final calldata = _deployedModule.contract
        .function('addCredential')
        .encodeCall([
          keypair.authData.publicKey.$1.value,
          keypair.authData.publicKey.$2.value,
          (wallet as _WebauthnExtendedWallet).uvRequired,
        ]);
    final tx = await wallet.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<Uint8List?> generateCredentialId(
    PassKeyPair keypair, [
    EthereumAddress? account,
  ]) async {
    final result = await wallet.readContract(
      address,
      webauthn_abi,
      'generateCredentialId',
      params: [
        keypair.authData.publicKey.$1.value,
        keypair.authData.publicKey.$2.value,
        (wallet as _WebauthnExtendedWallet).uvRequired,
        account ?? wallet.address,
      ],
    );
    return result.firstOrNull;
  }

  Future<BigInt?> getCredentialCount([EthereumAddress? account]) async {
    final result = await wallet.readContract(
      address,
      webauthn_abi,
      'getCredentialCount',
      params: [account ?? wallet.address],
    );
    return result.firstOrNull;
  }

  Future<List<Uint8List>?> getCredentialIds([EthereumAddress? account]) async {
    final result = await wallet.readContract(
      address,
      webauthn_abi,
      'getCredentialIds',
      params: [account ?? wallet.address],
    );
    return result.firstOrNull;
  }

  Future<(BigInt, BigInt, bool)?> getCredentialInfo(
    Uint8List credentialId, [
    EthereumAddress? account,
  ]) async {
    final result = await wallet.readContract(
      address,
      webauthn_abi,
      'getCredentialInfo',
      params: [credentialId, account ?? wallet.address],
    );
    return result.firstOrNull;
  }

  @override
  Uint8List getInitData() {
    return parseInitData(_initThreshold, _keyPair);
  }

  Future<bool?> hasCredential(
    PassKeyPair keypair, [
    EthereumAddress? account,
  ]) async {
    final result = await wallet.readContract(
      address,
      webauthn_abi,
      'hasCredential',
      params: [
        keypair.authData.publicKey.$1.value,
        keypair.authData.publicKey.$2.value,
        (wallet as _WebauthnExtendedWallet).uvRequired,
        account ?? wallet.address,
      ],
    );
    return result.firstOrNull;
  }

  Future<bool?> hasCredentialById(
    Uint8List credentialId, [
    EthereumAddress? account,
  ]) async {
    final result = await wallet.readContract(
      address,
      webauthn_abi,
      'hasCredentialById',
      params: [credentialId, account ?? wallet.address],
    );
    return result.firstOrNull;
  }

  Future<UserOperationReceipt?> removeCredential(PassKeyPair keypair) async {
    final calldata = _deployedModule.contract
        .function('removeCredential')
        .encodeCall([
          keypair.authData.publicKey.$1.value,
          keypair.authData.publicKey.$2.value,
          (wallet as _WebauthnExtendedWallet).uvRequired,
        ]);
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
      webauthn_abi,
      'threshold',
      params: [account ?? wallet.address],
    );
    return result.firstOrNull;
  }

  // must be static
  static EthereumAddress getAddress() {
    return EthereumAddress.fromHex(
      '0x47c3A1C003d1094A1B21C4d59ed286a224Fb8Fa3',
    );
  }

  static Uint8List parseInitData([
    BigInt? threshold,
    PassKeyPair? credentials,
    bool? uvRequired = true,
  ]) {
    return abi.encode(
      ["uint256", "(uint256,uint256,bool)[]"],
      [
        threshold,
        [
          [
            credentials?.authData.publicKey.$1.value,
            credentials?.authData.publicKey.$2.value,
            uvRequired,
          ],
        ],
      ],
    );
  }
}

class _WebauthnExtendedWallet extends SmartWallet {
  final PassKeyPair _keyPair;

  @protected
  final bool uvRequired;

  _WebauthnExtendedWallet.internal(super._state, this._keyPair, this.uvRequired)
    : assert(
        _state.signer is PassKeySigner,
        "[WebauthnValidator]: SmartWallet signer must be an instance of PasskeySigner",
      );

  factory _WebauthnExtendedWallet.fromWallet(
    SmartWallet wallet,
    PassKeyPair keyPair, [
    PassKeySigner? signer,
    bool uvRequired = true,
  ]) {
    if (wallet is _WebauthnExtendedWallet) {
      return wallet;
    }

    return _WebauthnExtendedWallet.internal(
      wallet.state.copyWith(signer: signer),
      keyPair,
      uvRequired,
    );
  }

  @override
  Future<UserOperation> prepareUserOperation(
    UserOperation op, {
    Uint256? nonceKey,
    String? signature,
  }) {
    Logger.warning(
      "nonceKey parameter is ignored; WebauthnValidator nonceKey will always be preffered",
    );
    nonceKey = Uint256.fromList(
      WebauthnValidator.getAddress().addressBytes.padToNBytes(
        24,
        direction: "right",
      ),
    );
    Logger.warning(
      "signer's dummySignature is ignored; WebauthnValidator generated dummySignature is preffered",
    );
    final dummySignature = _getDummySignature();
    return super.prepareUserOperation(
      op,
      nonceKey: nonceKey,
      signature: dummySignature,
    );
  }

  @override
  Future<String> generateSignature(
    UserOperation op,
    dynamic blockInfo,
    int? index,
  ) async {
    final signer = state.signer as PassKeySigner;
    final hash = op.hash(chain);
    final sig = await signer.signToPasskeySignature(
      hash,
      knownCredentials: [
        signer.credentialIdToType(_keyPair.authData.rawCredential),
      ],
    );
    final magic = await signer.isValidPassKeySignature(
      hash,
      sig,
      _keyPair,
      Addresses.p256VerifierAddress,
      chain.jsonRpcUrl!,
    );
    Logger.conditionalError(
      magic != ERC1271IsValidSignatureResponse.success,
      "Off-Chain Signature Validation failed! - Operation will revert with reason AA24.",
    );
    final credId = _getCredentialId();
    final webauthnSignature = _encodeSignature(credId, sig);
    return hexlify(webauthnSignature);
  }

  Uint8List _getCredentialId() {
    return keccak256(
      abi.encode(
        ["uint256", "uint256", "bool", "address"],
        [
          _keyPair.authData.publicKey.$1.value,
          _keyPair.authData.publicKey.$2.value,
          uvRequired,
          address,
        ],
      ),
    );
  }

  Uint8List _encodeSignature(Uint8List id, PassKeySignature sig) {
    return abi.encode(
      ["bytes32[]", "bool", "(bytes,string,uint256,uint256,uint256,uint256)[]"],
      [
        [id],
        true, // usePrecompile is always true
        [
          [
            sig.authData,
            sig.clientDataJSON,
            BigInt.from(sig.challengePos - 13), // `"challenge":"`
            BigInt.from(sig.typePos - 8), // `"type":"`
            sig.signature.$1.value,
            sig.signature.$2.value,
          ],
        ],
      ],
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

    final credId = _getCredentialId();
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

    final webauthnSignature = _encodeSignature(credId, sig);
    return hexlify(webauthnSignature);
  }
}
