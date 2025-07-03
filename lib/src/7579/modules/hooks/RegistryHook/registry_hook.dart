part of '../../../../../modules.dart';

class RegistryHook extends HookModuleInterface {
  static final _deployedModule = RegistryHookContract(getAddress());

  final Address _initRegistry;

  RegistryHook(super.wallet, [Address? registry])
    : _initRegistry =
          registry ??
          Address.fromHex('0x000000000069E2a187AEFFb852bF3cCdC95151B2');

  ///////////////////////////////////////////////////////////////
  //            GETTERS
  ///////////////////////////////////////////////////////////////
  @override
  Address get address => getAddress();

  @override
  Uint8List get initData => getInitData();

  @override
  String get name => "RegistryHook";

  @override
  ModuleType get type => ModuleType.hook;

  @override
  String get version => '1.0.0';

  ///////////////////////////////////////////////////////////////
  //            READS
  ///////////////////////////////////////////////////////////////
  @override
  Uint8List getInitData() {
    return _initRegistry.value;
  }

  Future<Address?> registry([Address? account]) async {
    final result = await contract.readContract(
      address,
      registry_hook_abi,
      'registry',
      params: [account ?? contract.address],
    );
    return result.firstOrNull;
  }

  //////////////////////////////////////////////////////////////////
  //            WRITES
  ///////////////////////////////////////////////////////////////
  Future<UserOperationReceipt?> setRegistry(Address registry) async {
    final calldata = _deployedModule.contract
        .function('setRegistry')
        .encodeCall([registry]);
    final tx = await contract.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  //////////////////////////////////////////////////////////////////
  //            STATIC METHODS
  ///////////////////////////////////////////////////////////////
  static Address getAddress() {
    return Address.fromHex('0x0ac6160DBA30d665cCA6e6b6a2CDf147DC3dED22');
  }
}
