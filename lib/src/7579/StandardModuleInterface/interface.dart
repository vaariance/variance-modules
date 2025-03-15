import 'dart:typed_data';
import 'package:variance_dart/variance_dart.dart'
    show
        Contract,
        ModuleInit,
        ModuleType,
        Safe7579Abis,
        SafeInitializer,
        SmartWallet,
        UserOperationResponse;
import 'package:web3dart/web3dart.dart';

part 'executors.dart';
part 'hooks.dart';
part 'validators.dart';

abstract interface class Base7579ModuleInterface {
  final SmartWallet wallet;

  Base7579ModuleInterface(this.wallet);

  // Module Name as defined in contract metadata
  String get name;

  // Module Version as defined in contract metadata
  String get version;

  // Module type
  ModuleType get type;

  // Module address
  EthereumAddress get address;

  // Returns the module intialization data
  Uint8List get initData;

  // Checks if the module is initialized
  Future<bool> isInitialized() async {
    final result = await wallet.readContract(
        address, Safe7579Abis.get('iModule'), 'isInitialized',
        params: [wallet.address], sender: wallet.address);
    return result.first;
  }

  // Checks if the expected module corresponds with the contract metadata
  Future<bool> isModuleType(ModuleType type) async {
    final result = await wallet.readContract(
        address, Safe7579Abis.get('iModule'), 'isModuleType',
        params: [BigInt.from(type.value)], sender: wallet.address);
    return result.first;
  }

  // Installs self in the [SmartWallet] instance
  // reverts if already installed
  Future<void> install() async {
    final tx = await wallet.installModule(type, address, initData);
    await tx.wait();
  }

  // Uninstalls self from the [SmartWallet] instance
  // reverts if not installed
  Future<void> uninstall() async {
    final tx = await wallet.uninstallModule(type, address, initData);
    await tx.wait();
  }
}

// This should be in a shared location accessible to both packages
abstract class Safe7579InitializerInterface extends SafeInitializer {
  EthereumAddress get launchpad;
  Iterable<ModuleInit>? get validators;
  Iterable<ModuleInit>? get executors;
  Iterable<ModuleInit>? get fallbacks;
  Iterable<ModuleInit>? get hooks;
  Iterable<EthereumAddress>? get attesters;
  int? get attestersThreshold;

  Uint8List getLaunchpadInitData();
}
