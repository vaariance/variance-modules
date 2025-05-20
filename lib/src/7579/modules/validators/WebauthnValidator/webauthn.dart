part of '../../../../../modules.dart';

class WebauthnValidator extends ValidatorModuleInterface {
  static final _deployedModule = WebauthnContract(getAddress());

  final BigInt _initThreshold;

  final PassKeyPair _keyPair;

  WebauthnValidator(SmartWallet wallet, this._initThreshold, this._keyPair)
    : assert(
        _initThreshold == BigInt.one,
        ModuleVariablesNotSetError('WebAuthnValidator', 'threshold'),
      ),
      super(_WebauthnExtendedWallet.fromWallet(wallet, _keyPair));

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
          true,
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
        true,
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
        true,
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
          true,
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
  ]) {
    return abi.encode(
      ["uint256", "(uint256,uint256,bool)[]"],
      [
        threshold,
        [
          [
            credentials?.authData.publicKey.$1.value,
            credentials?.authData.publicKey.$2.value,
            true,
          ],
        ],
      ],
    );
  }
}

class _WebauthnExtendedWallet extends SmartWallet {
  final PassKeyPair _keyPair;
  _WebauthnExtendedWallet(super._state, this._keyPair);

  factory _WebauthnExtendedWallet.fromWallet(
    SmartWallet wallet,
    PassKeyPair keyPair,
  ) {
    if (wallet is _WebauthnExtendedWallet) {
      return wallet;
    }
    return _WebauthnExtendedWallet(wallet.state, keyPair);
  }

  @override
  Future<UserOperationResponse> sendUserOperation(
    UserOperation op, {
    Uint256? nonceKey,
  }) {
    Logger.warning(
      "nonceKey parameter is ignored; Validator nonce key will always be preffered",
    );
    nonceKey = Uint256.fromList(
      WebauthnValidator.getAddress().addressBytes.padRightTo32Bytes(),
    );
    return super.sendUserOperation(op, nonceKey: nonceKey);
  }

  @override
  Future<String> generateSignature(
    UserOperation op,
    dynamic blockInfo,
    int? index,
  ) async {
    final signer = state.signer as PassKeySigner;
    final hash = op.hash(chain);
    final sig = await signer.signToPasskeySignature(hash);
    final activeCredentialId = keccak256(
      abi.encode(
        ["uint256", "uint256", "bool", "address"],
        [
          _keyPair.authData.publicKey.$1.value,
          _keyPair.authData.publicKey.$2.value,
          true,
          address,
        ],
      ),
    );
    final webauthnSignature = abi.encode(
      ["bytes32[]", "bool", "(bytes,string,uint256,uint256,uint256,uint256)[]"],
      [
        [activeCredentialId],
        true,
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
    return hexlify(webauthnSignature);
  }
}
