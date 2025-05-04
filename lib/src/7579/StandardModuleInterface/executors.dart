part of 'interface.dart';

abstract class ExecutorModuleInterface extends Base7579ModuleInterface {
  ExecutorModuleInterface(super.wallet);

  final ContractAbi _abi = ContractAbi.fromJson(
      '[{"type":"function","name":"getExecutorsPaginated","inputs":[{"name":"cursor","type":"address","internalType":"address"},{"name":"pageSize","type":"uint256","internalType":"uint256"}],"outputs":[{"name":"array","type":"address[]","internalType":"address[]"},{"name":"next","type":"address","internalType":"address"}],"stateMutability":"view"}]',
      "getExecutorsPaginated");

  // calls the executor module to execute a function call on the account
  // entrypoint => account (execute) -> module (execute) -> adapter (executeFromExecutor) ->
  Future<UserOperationResponse> execute(Uint8List encodedFunctionCall) {
    final innerCallData = Contract.encodeFunctionCall(
        'execute', address, Safe7579Abis.get('iModule'), [encodedFunctionCall]);
    return wallet.sendTransaction(wallet.address, innerCallData);
  }

  Future<List<EthereumAddress>> getInstalledExecutors() async {
    final result = await wallet.readContract(wallet.address, _abi, _abi.name,
        params: [SENTINEL_ADDRESS, BigInt.from(100)], sender: wallet.address);
    final modules = List<EthereumAddress>.from(result.first);
    return modules;
  }

  Future<EthereumAddress> prevExecutor() async {
    final executors = await getInstalledExecutors();
    final index = executors.indexOf(address);
    if (index == 0) {
      return SENTINEL_ADDRESS;
    } else if (index > 0) {
      return executors[index - 1];
    } else {
      throw Exception('Executor not found');
    }
  }

  @override
  Future<Uint8List> getDeInitData([Uint8List? context]) async {
    final prev = await prevExecutor();
    return abi.encode(["address", "bytes"], [prev, context ?? Uint8List(0)]);
  }
}
