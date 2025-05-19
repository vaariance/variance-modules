import 'dart:typed_data';

import 'package:variance_dart/variance_dart.dart'
    show
        Contract,
        ModuleType,
        Safe7579Abis,
        SmartWallet,
        UserOperationReceipt,
        SENTINEL_ADDRESS,
        UserOperationResponse;
import 'package:web3_signers/web3_signers.dart';
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
      address,
      Safe7579Abis.get('iModule'),
      'isInitialized',
      params: [wallet.address],
      sender: wallet.address,
    );
    return result.first;
  }

  // Checks if the expected module corresponds with the contract metadata
  Future<bool> isModuleType(ModuleType type) async {
    final result = await wallet.readContract(
      address,
      Safe7579Abis.get('iModule'),
      'isModuleType',
      params: [BigInt.from(type.value)],
      sender: wallet.address,
    );
    return result.first;
  }

  // Installs self in the [SmartWallet] instance
  // reverts if already installed
  Future<UserOperationReceipt?> install() async {
    final tx = await wallet.installModule(type, address, initData);
    final receipt = await tx.wait();
    return receipt;
  }

  // Uninstalls self from the [SmartWallet] instance
  // reverts if not installed
  Future<UserOperationReceipt?> uninstall([Uint8List? context]) async {
    final deInitData = await getDeInitData(context);
    final tx = await wallet.uninstallModule(type, address, deInitData);
    final receipt = await tx.wait();
    return receipt;
  }

  /// Returns the initialization data required for this module
  ///
  /// This data is used during module installation to properly configure
  /// the module for the smart wallet
  Uint8List getInitData();

  Future<Uint8List> getDeInitData([Uint8List? context]) {
    return Future.value(context ?? Uint8List(0));
  }
}
