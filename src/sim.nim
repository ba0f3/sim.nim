import parsecfg, tables, strutils, strformat, pegs
import macros except `!`

type
  KeyNotFoundException* = object of KeyError
  SectionNotFoundException* = object of KeyError


template defaultValue*(x: untyped) {.pragma.}

proc `!`(s: string): string {.compileTime.} =
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
  elif T is int64:
    result = parseInt(s).int64
  elif T is uint64:
    result = parseInt(s).uint64
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

proc getValue[T](cfg: Config, t: typedesc[T], section, key: string): T = getValue(cfg, result, section, key)

proc getValue[T](cfg: Config, value: var T, section, key: string) {.compileTime.} =
  echo "section '", section, "' key ", key
  if section.len == 0:
    if T is object:
      if not cfg.hasKey(key):
        raise newException(SectionNotFoundException, &"Section `{key}` not found")
    else:
      if not cfg[""].hasKey(key):
        raise newException(KeyNotFoundException, &"Key `{key}` not found in top level section")
  else:
    if not cfg[section].hasKey(key):
      raise newException(KeyNotFoundException, &"Key `{key}` not found in section `{section}`")

  let v = cfg.getSectionValue(section, key)
  when T is seq:
    var children: seq[string]
    when value[0].type is object:
      let len = v.len
      if len > 0 and v[len-1] == '*':
        let prefix = v[0..len-2]
        for key in cfg.keys:
          if key.startsWith(prefix):
            children.add(key)
      else:
        children = v.split(',')
    else:
      children = v.split(',')
    for child in children:
      when value[0].type is object:
        value.add(getValue(cfg, value[0].type, "", child))
      elif value[0].type is string:
        value.add(child)
      else:
        if child.len > 0:
          value.add(convert[value[0].type](child))
  elif T is object:
    for k, v in value.fieldPairs():
      cfg.getValue(v, key, !k)
  else:
    value = convert[T](v)

proc to*[T](filename: string): T =
  ## Load config from file and convert it to an object
  let cfg = loadConfig(filename)
  for k, v in result.fieldPairs():
    try:
      cfg.getValue(v, "", !k)
    except KeyNotFoundException:
      when v.hasCustomPragma(defaultValue):
        v = v.getCustomPragmaVal(defaultValue)
      else:
        raise

