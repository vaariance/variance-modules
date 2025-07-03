// ignore_for_file: public_member_api_docs, sort_constructors_first
part of '../../../../../modules.dart';

class OwnableExecutor extends ExecutorModuleInterface {
  static final _deployedModule = OwnableExecutorContract(getAddress());

  final Address _initialOwner;

  OwnableExecutor(super.wallet, this._initialOwner);

  ///////////////////////////////////////////////////////////////
  //            GETTERS
  ///////////////////////////////////////////////////////////////
  @override
  Address get address => getAddress();

  @override
  Uint8List get initData => getInitData();

  @override
  String get name => 'OwnableExecutor';

  @override
  ModuleType get type => ModuleType.executor;

  @override
  String get version => '1.0.0';

  ///////////////////////////////////////////////////////////////
  //            READS
  ///////////////////////////////////////////////////////////////

  @override
  Uint8List getInitData() {
    return _initialOwner.value;
  }

  Future<List<Address>?> getOwners([Address? account]) async {
    final result = await contract.readContract(
      address,
      ownable_executor_abi,
      'getOwners',
      params: [account ?? contract.address],
    );
    return result.firstOrNull;
  }

  Future<BigInt?> ownerCount([Address? account]) async {
    final result = await contract.readContract(
      address,
      ownable_executor_abi,
      'ownerCount',
      params: [account ?? contract.address],
    );
    return result.firstOrNull;
  }

  //////////////////////////////////////////////////////////////////
  //            WRITES
  ///////////////////////////////////////////////////////////////
  Future<UserOperationReceipt?> addOwner(Address owner) async {
    final calldata = _deployedModule.contract.function('addOwner').encodeCall([
      owner,
    ]);
    final tx = await contract.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> removeOwner(Address owner) async {
    final oowners = await getOwners() ?? [];
    final currentOwnerIndex = oowners.indexOf(owner);

    Address prevOwner;
    if (currentOwnerIndex == -1) {
      throw Exception('Owner not found');
    } else if (currentOwnerIndex == 0) {
      prevOwner = SENTINEL_ADDRESS;
    } else {
      prevOwner = oowners[currentOwnerIndex - 1];
    }
    final calldata = _deployedModule.contract
        .function('removeOwner')
        .encodeCall([prevOwner, owner]);
    final tx = await contract.sendTransaction(address, calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> executeOnOwnedAccount(
    Address ownedAccount,
    Uint8List data,
  ) async {
    final calldata = _deployedModule.contract
        .function('executeOnOwnedAccount')
        .encodeCall([ownedAccount, data]);
    final tx = await contract.sendTransaction(getAddress(), calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  Future<UserOperationReceipt?> executeBatchOnOwnedAccount(
    Address ownedAccount,
    Uint8List data,
  ) async {
    final calldata = _deployedModule.contract
        .function('executeBatchOnOwnedAccount')
        .encodeCall([ownedAccount, data]);
    final tx = await contract.sendTransaction(getAddress(), calldata);
    final receipt = await tx.wait();
    return receipt;
  }

  //////////////////////////////////////////////////////////////////
  //            STATIC METHODS
  ///////////////////////////////////////////////////////////////
  static Address getAddress() {
    return Address.fromHex('0x4Fd8d57b94966982B62e9588C27B4171B55E8354');
  }
}
