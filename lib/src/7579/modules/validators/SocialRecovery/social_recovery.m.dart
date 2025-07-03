// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated from lib/src/7579/modules/validators/SocialRecovery/social_recovery.abi.json

// ignore_for_file: non_constant_identifier_names

import 'package:web3dart/web3dart.dart';
import 'package:web3_signers/web3_signers.dart';

/// The ABI string exported from the original .abi.json file.
final ContractAbi social_recovery_abi = ContractAbi.fromJson('[{"inputs":[{"internalType":"address","name":"guardian","type":"address"}],"name":"addGuardian","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"getGuardians","outputs":[{"internalType":"address[]","name":"guardiansArray","type":"address[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"guardianCount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"prevGuardian","type":"address"},{"internalType":"address","name":"guardian","type":"address"}],"name":"removeGuardian","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_threshold","type":"uint256"}],"name":"setThreshold","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"threshold","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]', 'social_recovery');

/// A helper class for the contract.
/// You must provide the contract [address] when instantiating.
class SocialRecoveryContract {
  final DeployedContract contract;

  SocialRecoveryContract(Address address)
      : contract = DeployedContract(social_recovery_abi, address);
}
