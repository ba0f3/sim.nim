import parsecfg, tables, strutils, strformat

proc camelCaseToSnakeCase(s: string): string =
  var first = true
  for c in s:
    if c.isUpperAscii():
      if not first:
        result.add('_')
      result.add(c.toLowerAscii())
    else:
      result.add(c)
    first = false

proc convert[T](s: string): T =
  when T is int:
    result = parseInt(s)
  elif T is uint:
    result = parseInt(s).uint
  elif T is int32:
    result = parseInt(s).int32
  elif T is uint32:
    result = parseInt(s).uint32
  elif T is int16:
    result = parseInt(s).int16
  elif T is uint16:
    result = parseInt(s).uint16
  elif T is int8:
    result = parseInt(s).int8
  elif T is uint8:
    result = parseInt(s).uint8
  elif T is char:
    result = s[0]
  elif T is bool:
    if s == "on" or s == "true":
      result = true
    elif s == "off" or s == "false":
      result = false
    else:
      result = parseInt(s) > 0
  elif T is float:
    result = parseFloat(s)
  elif T is string:
    result = s

proc getValue[T](cfg: Config, value: var T, section, key: string)

proc getValue[T](cfg: Config, t: typedesc[T], section, key: string): T =
  getValue(cfg, result, section, key)

proc getValue[T](cfg: Config, value: var T, section, key: string) =
  var key = camelCaseToSnakeCase(key)

  if section.len != 0 and not cfg.hasKey(section):
    raise newException(KeyError, &"Section `{section}` not found")

  when T isnot object:
    if not cfg[section].hasKey(key):
      if section.len == 0:
        raise newException(KeyError, &"Key `{key}` not found")
      else:
        raise newException(KeyError, &"Key `{key}` not found in section `{section}`")
  let v = cfg.getSectionValue(section, key)
  #echo section, "[", key, "] => ", v
  when T is seq:
    let items = v.split(',')
    for item in items:
      when value[0].type is object:
        value.add(getValue(cfg, value[0].type, "", item))
      else:
        value.add(convert[value[0].type](item))
  elif T is object:
    for k, v in value.fieldPairs():
      cfg.getValue(v, key, k)
  else:
    value = convert[T](v)

proc to*[T](filename: string): T =
  ## Load config from file and convert it to an object
  let cfg = loadConfig(filename)
  for key, value in result.fieldPairs():
    cfg.getValue(value, "", key)
