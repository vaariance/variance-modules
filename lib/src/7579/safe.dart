// ignore_for_file: unused_element_parameter

part of '../../variance_modules.dart';

class _Safe7579Initializer extends _SafeInitializer {
  final EthereumAddress launchpad;
  final Iterable<ModuleInit>? validators;
  final Iterable<ModuleInit>? executors;
  final Iterable<ModuleInit>? fallbacks;
  final Iterable<ModuleInit>? hooks;
  final Iterable<EthereumAddress>? attesters;
  final int? attestersThreshold;

  _Safe7579Initializer({
    required super.owners,
    required super.threshold,
    required super.module,
    required super.singleton,
    required this.launchpad,
    this.validators,
    this.executors,
    this.fallbacks,
    this.hooks,
    this.attesters,
    this.attestersThreshold,
  });

  Uint8List getLaunchpadInitData() {
    return encode7579LaunchpadInitdata(
        launchpad: launchpad,
        module: module,
        attesters: attesters,
        executors: executors,
        fallbacks: fallbacks,
        hooks: hooks,
        attestersThreshold: attestersThreshold);
  }

  @override
  Uint8List getInitializer() {
    final initData = getLaunchpadInitData();
    final initHash = get7579InitHash(
        launchpadInitData: initData,
        launchpad: launchpad,
        owners: owners,
        threshold: threshold,
        module: module,
        singleton: singleton);
    return encode7579InitCalldata(launchpad: launchpad, initHash: initHash);
  }
}

class _SafeInitializer {
  final Iterable<EthereumAddress> owners;
  final int threshold;
  final Safe4337ModuleAddress module;
  final SafeSingletonAddress singleton;
  final Uint8List Function(Uint8List Function())? encodeWebauthnSetup;

  _SafeInitializer({
    required this.owners,
    required this.threshold,
    required this.module,
    required this.singleton,
    this.encodeWebauthnSetup,
  });

  /// Generates the initializer data for deploying a new Safe contract.
  ///
  /// Returns a [Uint8List] containing the encoded initializer data.
  Uint8List getInitializer() {
    encodeModuleSetup() {
      return Contract.encodeFunctionCall(
          "enableModules", module.setup, ContractAbis.get("enableModules"), [
        [module.address]
      ]);
    }

    final setup = {
      "owners": owners.toList(),
      "threshold": BigInt.from(threshold),
      "to": null,
      "data": null,
      "fallbackHandler": module.address,
    };

    if (encodeWebauthnSetup != null) {
      setup["to"] = Addresses.safeMultiSendaddress;
      setup["data"] = encodeWebauthnSetup!(encodeModuleSetup);
    } else {
      setup["to"] = module.setup;
      setup["data"] = encodeModuleSetup();
    }

    return Contract.encodeFunctionCall(
        "setup", singleton.address, ContractAbis.get("setup"), [
      setup["owners"],
      setup["threshold"],
      setup["to"],
      setup["data"],
      setup["fallbackHandler"],
      Addresses.zeroAddress,
      BigInt.zero,
      Addresses.zeroAddress,
    ]);
  }
}
