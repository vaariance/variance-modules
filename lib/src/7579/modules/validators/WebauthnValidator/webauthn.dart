part of '../../../../../modules.dart';

class WebauthnValidator extends ValidatorModuleInterface {
  static final _deployedModule = WebauthnContract(getAddress());

  final BigInt _initThreshold;

  final Set<PassKeyPair> _keyPairs;

  WebauthnValidator(
    SmartWallet wallet,
    this._initThreshold,
    this._keyPairs, {
    PassKeySigner? signer,
    bool uvRequired = true,
  }) : assert(
         _initThreshold.toInt() == _keyPairs.length,
         ModuleVariableError('WebAuthnValidator', 'threshold'),
       ),
       super(
         _WebauthnWalletExtension.fromWallet(
           wallet,
           _keyPairs,
           signer,
           uvRequired,
         ),
       );

  ///////////////////////////////////////////////////////////////
  //            GETTERS
  ///////////////////////////////////////////////////////////////
  @override
  Address get address => getAddress();

  @override
  Uint8List get initData => getInitData();

  @override
  String get name => "WebAuthnValidator";

  @override
  ModuleType get type => ModuleType.validator;

  @override
  String get version => "1.0.0";

  bool get _uvRequired => (contract as _WebauthnWalletExtension).uvRequired;

  ///////////////////////////////////////////////////////////////
  //            READS
  ///////////////////////////////////////////////////////////////
  @override
  Uint8List getInitData() {
    return parseInitData(_initThreshold, _keyPairs);
  }

  Future<Uint8List?> generateCredentialId(
    PassKeyPair keypair, [
    Address? account,
  ]) async {
    final result = await contract.readContract(
      address,
      webauthn_abi,
      'generateCredentialId',
      params: [
        keypair.authData.publicKey.$1.value,
        keypair.authData.publicKey.$2.value,
        _uvRequired,
        account ?? contract.address,
      ],
    );
    return result.firstOrNull;
  }

  Future<BigInt?> getCredentialCount([Address? account]) async {
    final result = await contract.readContract(
      address,
      webauthn_abi,
      'getCredentialCount',
      params: [account ?? contract.address],
    );
    return result.firstOrNull;
  }

  Future<List<Uint8List>?> getCredentialIds([Address? account]) async {
    final result = await contract.readContract(
      address,
      webauthn_abi,
      'getCredentialIds',
      params: [account ?? contract.address],
    );
    return result.firstOrNull;
  }

  Future<(BigInt, BigInt, bool)?> getCredentialInfo(
    Uint8List credentialId, [
    Address? account,
  ]) async {
    final result = await contract.readContract(
      address,
      webauthn_abi,
      'getCredentialInfo',
      params: [credentialId, account ?? contract.address],
    );
    return result.firstOrNull;
  }

  Future<bool?> hasCredential(PassKeyPair keypair, [Address? account]) async {
    final result = await contract.readContract(
      address,
      webauthn_abi,
      'hasCredential',
      params: [
        keypair.authData.publicKey.$1.value,
        keypair.authData.publicKey.$2.value,
        _uvRequired,
        account ?? contract.address,
      ],
    );
    return result.firstOrNull;
  }

  Future<bool?> hasCredentialById(
    Uint8List credentialId, [
    Address? account,
  ]) async {
    final result = await contract.readContract(
      address,
      webauthn_abi,
      'hasCredentialById',
      params: [credentialId, account ?? contract.address],
    );
    return result.firstOrNull;
  }

  Future<BigInt?> threshold([Address? account]) async {
    final result = await contract.readContract(
      address,
      webauthn_abi,
      'threshold',
      params: [account ?? contract.address],
    );
    return result.firstOrNull;
  }

  //////////////////////////////////////////////////////////////////
  //            WRITES
  ///////////////////////////////////////////////////////////////
  Future<UserOperationReceipt?> addCredential(
    PassKeyPair keypair, [
    SmartContract? sc,
  ]) async {
    final calldata = _deployedModule.contract
        .function('addCredential')
        .encodeCall([
          keypair.authData.publicKey.$1.value,
          keypair.authData.publicKey.$2.value,
          _uvRequired,
        ]);
    final tx = await (sc ?? contract).sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> removeCredential(
    PassKeyPair keypair, [
    SmartContract? sc,
  ]) async {
    final calldata = _deployedModule.contract
        .function('removeCredential')
        .encodeCall([
          keypair.authData.publicKey.$1.value,
          keypair.authData.publicKey.$2.value,
          _uvRequired,
        ]);
    final tx = await (sc ?? contract).sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> setThreshold(
    int threshold, [
    SmartContract? sc,
  ]) async {
    final calldata = _deployedModule.contract
        .function('setThreshold')
        .encodeCall([BigInt.from(threshold)]);
    final tx = await (sc ?? contract).sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  @override
  Future<UserOperationResponse> proxyTransaction(
    List<Address> recipients,
    List<Uint8List> calls, {
    List<BigInt>? amountsInWei,
  }) {
    return (contract as _WebauthnWalletExtension).sendBatchedTransaction(
      recipients,
      calls,
      amountsInWei: amountsInWei,
    );
  }

  //////////////////////////////////////////////////////////////////
  //            STATIC METHODS
  ///////////////////////////////////////////////////////////////
  static Address getAddress() {
    return Address.fromHex('0x47c3A1C003d1094A1B21C4d59ed286a224Fb8Fa3');
  }

  static Uint8List parseInitData(
    BigInt threshold,
    Set<PassKeyPair> credentials, [
    bool? uvRequired = true,
  ]) {
    return abi.encode(
      ["uint256", "(uint256,uint256,bool)[]"],
      [
        threshold,
        [
          ...credentials.map(
            (credential) => [
              credential.authData.publicKey.$1.value,
              credential.authData.publicKey.$2.value,
              uvRequired,
            ],
          ),
        ],
      ],
    );
  }
}
