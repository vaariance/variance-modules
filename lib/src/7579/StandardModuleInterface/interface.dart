import 'package:flutter/foundation.dart';
import 'package:variance_dart/variance_dart.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:web3dart/web3dart.dart';

part 'executors.dart';
part 'hooks.dart';
part 'validators.dart';

abstract interface class Base7579ModuleInterface {
  final SmartWallet _wallet;

  Base7579ModuleInterface(this._wallet);

  // returns an interface with only contract related functions
  @protected
  SmartContract get contract => _wallet;

  // Module Name as defined in contract metadata
  String get name;

  // Module Version as defined in contract metadata
  String get version;

  // Module type
  ModuleType get type;

  // Module address
  Address get address;

  // Returns the module intialization data
  Uint8List get initData;

  // Checks if the module is initialized
  Future<bool> isInitialized() async {
    final result = await _wallet.readContract(
      address,
      Safe7579Abis.get('iModule'),
      'isInitialized',
      params: [_wallet.address],
      sender: _wallet.address,
    );
    return result.first;
  }

  // Checks if the expected module corresponds with the contract metadata
  Future<bool> isModuleType(ModuleType type) async {
    final result = await _wallet.readContract(
      address,
      Safe7579Abis.get('iModule'),
      'isModuleType',
      params: [BigInt.from(type.value)],
      sender: _wallet.address,
    );
    return result.first;
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
