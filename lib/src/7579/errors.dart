class ModuleVariablesNotSetError extends Error {
  final String _module;
  final String _reason;
  ModuleVariablesNotSetError(this._module, this._reason);

  @override
  String toString() {
    return '''ModuleVariablesNotSetError: $_module Module requires all variables used by the initData to be set - is $_reason set?
    \n Usage:
    \n 1. Set the variables in the module
    \n    $_module.setInitVars($_reason);
    \n 2. Instantiate the module
    \n    $_module(<SmartWallet>);
    \n 3. Get the initData to confirm the variables are set
    \n    $_module.getInitData();
    ''';
  }
}
