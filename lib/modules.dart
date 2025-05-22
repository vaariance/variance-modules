library;

import 'package:flutter/foundation.dart';
import 'package:variance_dart/variance_dart.dart';
import 'package:variance_modules/src/7579/errors.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:web3dart/crypto.dart';

import 'src/7579/StandardModuleInterface/interface.dart';
import 'src/7579/modules/executors/OwnableExecutor/ownable_executor.m.dart';
import 'src/7579/modules/hooks/RegistryHook/registry_hook.m.dart';
import 'src/7579/modules/validators/OwnableValidator/ownable_validator.m.dart';
import 'src/7579/modules/validators/SocialRecovery/social_recovery.m.dart';
import 'src/7579/modules/validators/WebauthnValidator/webauthn.m.dart';

export 'src/7579/StandardModuleInterface/interface.dart';

// ------------ EXECUTORS -------------- //
part 'src/7579/modules/executors/OwnableExecutor/ownable_executor.dart';
// ------------ HOOKS -------------- //
part 'src/7579/modules/hooks/RegistryHook/registry_hook.dart';
// ------------ VALIDATORS -------------- //
part 'src/7579/modules/validators/OwnableValidator/ownable_validator.dart';
part 'src/7579/modules/validators/SocialRecovery/social_recovery.dart';
part 'src/7579/modules/validators/WebauthnValidator/webauthn.dart';
