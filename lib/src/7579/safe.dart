// ignore_for_file: unused_element_parameter

part of '../../variance_modules.dart';

class _Safe7579Initializer extends BaseSafeInitializer {
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
    super.encodeWebauthnSetup,
  });

  /// Generates the launchpad initialization data.
  ///
  /// Returns a [Uint8List] containing the encoded initialization data.
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
