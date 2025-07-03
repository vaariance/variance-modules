// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated from lib/src/7579/modules/hooks/RegistryHook/registry_hook.abi.json

// ignore_for_file: non_constant_identifier_names

import 'package:web3dart/web3dart.dart';
import 'package:web3_signers/web3_signers.dart';

/// The ABI string exported from the original .abi.json file.
final ContractAbi registry_hook_abi = ContractAbi.fromJson('[{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"registry","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_registry","type":"address"}],"name":"setRegistry","outputs":[],"stateMutability":"nonpayable","type":"function"}]', 'registry_hook');

/// A helper class for the contract.
/// You must provide the contract [address] when instantiating.
class RegistryHookContract {
  final DeployedContract contract;

  RegistryHookContract(Address address)
      : contract = DeployedContract(registry_hook_abi, address);
}
