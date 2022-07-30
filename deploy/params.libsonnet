
// this file returns the params for the current qbec environment
// local env = std.extVar('qbec.io/env');
// local paramsMap = import 'glob-import:environments/*.libsonnet';
// local baseFile = if env == '_' then 'base' else env;
// local key = 'environments/%s.libsonnet' % baseFile;

// if std.objectHas(paramsMap, key)
// then paramsMap[key]
// else error 'no param file %s found for environment %s' % [key, env]

// this file returns the params for the current qbec environment
// you need to add an entry here every time you add a new environment.

local env = std.extVar('qbec.io/env');
local paramsMap = {
  _: import './environments/base.libsonnet',
  default: import './environments/default.libsonnet',
  stage: import './environments/base.libsonnet',
};

if std.objectHas(paramsMap, env) then paramsMap[env] else error 'environment ' + env + ' not defined in ' + std.thisFile