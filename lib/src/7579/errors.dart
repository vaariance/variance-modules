class ModuleVariableError extends Error {
  final String _module;
  final String _reason;
  ModuleVariableError(this._module, this._reason);

  @override
  String toString() {
    return '''ModuleVariableError: $_module Module requires all variables used by the initData to be set - is $_reason set?
    \n Usage:
    \n 1. Instantiate the module with a SmartWallet and all required variables set
    \n    $_module(<SmartWallet>, $_reason);
    \n 2. Get the initData to confirm the variables are set
    \n    $_module.getInitData();
    Additionally, if you set provided the correct arguments, check the arguments are valid.
    ''';
  }
}
