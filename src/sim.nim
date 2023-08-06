import parsecfg, tables, strutils, strformat, streams
import macros except `!`
import std/enumutils

type
  SimParsingException* = object of ValueError
  KeyNotFoundException* = object of SimParsingException
    ## Raise when non-default key not found in ini file
  SectionNotFoundException* = object of SimParsingException
    ## Raise when section not found in ini file
  SectionNameException* = object of SimParsingException
  InvalidValueException* = object of SimParsingException

template defaultValue*(x: untyped) {.pragma.}

template ignore*() {.pragma.}
template parseHook*(x: untyped) {.pragma.}


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

converter toInt*(s: string): int = parseInt(s)
converter toInt64*(s: string): int64 = parseInt(s).int64
converter toInt32*(s: string): int32 = parseInt(s).int32
converter toInt16*(s: string): int16 = parseInt(s).int16
converter toInt8*(s: string): int8 = parseInt(s).int8

converter toUInt*(s: string): uint = parseUInt(s)
converter toUInt64*(s: string): uint64 = parseUInt(s).uint64
converter toUInt32*(s: string): uint32 = parseUInt(s).uint32
converter toUInt16*(s: string): uint16 = parseUInt(s).uint16
converter toUInt8*(s: string): uint8 = parseUInt(s).uint8

converter toFloat*(s: string): float = parseFloat(s)
converter toFloat64*(s: string): float64 = parseFloat(s).float64
converter toFloat32*(s: string): float32 = parseFloat(s).float32

converter toChar*(s: string): char = result = if s.len > 0: s[0] else: char(0)

converter toByte*(s: string): byte = toChar(s).byte

converter toBool*(s: string): bool =
  if s[0] == 'o':
    return s[1] == 'n'
  elif s[0] == 't' or s[0] == 'T' or s[0] == '1':
    return true
  elif s[0] == 'f' or s[0] == 'F' or s[0] == '0':
    return false
  raise new ValueError

proc toEnum*[T](s: string): T =
  try:
    let val = parseInt(s)
    result = cast[T](val)
  except ValueError:
    for k in items(T):
      if $k.T == s:
        return k.T

template convert[T](s: string): T =
  when T is enum:
    toEnum[T](s)
  else:
    s

type
  Section = object
    name: string
    inheritFrom: string
  Sim = object
    useSnakeCase: bool
    sections: Table[string, Section]
    cfg: Config

proc getValue[T](sim: Sim, value: var T, key: string, section = "")
proc getValue[T](sim: Sim, t: typedesc[T], key: string, section = ""): T = sim.getValue(result, key, section)

proc getSeq[T: seq](sim: Sim, value: var T, section, key: string) =
  let v = sim.cfg.getSectionValue(section, key)
  if v.len == 0 and sim.sections.hasKey(key):
    when value[0].type is enum:
      # Use section keys as enums
      for k in sim.cfg[key].keys:
        value.add(convert[value[0].type](k))
  else:
    var children: seq[string]
    when value[0].type is object:
      let len = v.len
      if len > 0 and v[len-1] == '*':
        let prefix = v[0..len-2]
        for key in sim.cfg.keys:
          if key.startsWith(prefix):
            children.add(key)
      else:
        children = v.split(',')
    else:
      children = v.split(',')
    for child in children:
      when value[0].type is object:
        value.add(sim.getValue(value[0].type, child))
      elif value[0].type is string:
        value.add(child)
      else:
        if child.len > 0:
          value.add(convert[value[0].type](child))

proc getObj[T: object](sim: Sim, value: var T, section: string = "", key: string = "") =
  let v {.used.} = sim.cfg.getSectionValue(section, key)
  var key = key
  if section.len != 0:
    key = &"{section}/{key}"

  for k, v in value.fieldPairs():
    when not v.hasCustomPragma(ignore):
      try:
        when v.hasCustomPragma(parseHook):
          let
            fn = v.getCustomPragmaVal(parseHook)
            input = sim.cfg.getSectionValue(key, if sim.useSnakeCase: !k else: k)
          v = fn(input)
        else:
          sim.getValue(v, if sim.useSnakeCase: !k else: k, key)
      except SectionNotFoundException, KeyNotFoundException:
        when v.hasCustomPragma(defaultValue):
          v = v.getCustomPragmaVal(defaultValue)
        else:
          raise


proc getValue[T](sim: Sim, value: var T, key: string, section = "") =
  var section = section
  if section.len == 0:
    when T is object:
      if not sim.sections.hasKey(key):
         raise newException(SectionNotFoundException, &"Section `{key}` not found")
    else:
      if "" notin sim.cfg or key notin sim.cfg[""]:
        when T is seq:
          if not sim.sections.hasKey(key):
            raise newException(KeyNotFoundException, &"Key `{key}` not found in top level section")
        else:
          raise newException(KeyNotFoundException, &"Key `{key}` not found in top level section")
  else:
    when T is object:
      let name = &"{section}/{key}"
      if not sim.sections.hasKey(name):
        raise newException(SectionNotFoundException, &"Section `{name}` not found")
    else:
      var s = sim.sections[section]
      if not sim.cfg[s.name].hasKey(key):
        while s.inheritFrom.len != 0:
          section = s.inheritFrom
          if not sim.cfg.hasKey(section):
            section = sim.sections[section].name
          if not sim.cfg[section].hasKey(key):
            s = sim.sections[section]
          else:
            break
        if not sim.cfg[section].hasKey(key):
          raise newException(KeyNotFoundException, &"Key `{key}` not found in section `{section}`")

  when T is seq:
    getSeq(sim, value, section, key)
  elif T is object:
    getObj(sim, value, section, key)
  else:
    let v = sim.cfg.getSectionValue(section, key)
    try:
      value = convert[T](v)
    except ValueError:
      raise newException(InvalidValueException, &"Invalid value for key `{key}` ({v}) in section `{section}`")

proc mapSection(sim: var Sim) =
  for name in sim.cfg.keys:
    var section = Section(name: name)
    if unlikely('.' in name):
      let parts = name.split('.')
      if parts.len != 2:
        raise newException(SectionNameException, &"Multiple inheritance is not supported `{section}`")
      if parts[0].len == 0 or parts[1].len == 0:
        raise newException(SectionNameException, &"Part(s) of section name is empty `{section}`")
      section.inheritFrom = parts[1]

      var alias = Section(
        name: name,
        inheritFrom: parts[1]
        )
      sim.sections[parts[0]] = alias
    sim.sections[section.name] = section

proc loadObject*[T](stream: Stream, useSnakeCase = true, filename = "[stream]"): T =
  ## Load config from file and convert it to an object
  var sim = Sim(
    useSnakeCase: useSnakeCase,
    cfg: stream.loadConfig(filename),
    sections: initTable[string, Section]()
  )
  sim.mapSection()
  sim.getObj(result)

proc loadObject*[T](filename: string, useSnakeCase = true): T =
  let file = open(filename, fmRead)
  let fileStream = newFileStream(file)
  defer: fileStream.close()
  result = loadObject[T](fileStream, useSnakeCase, filename)


proc to*[T](filename: string): T {.deprecated: "Use loadObject instead", inline.} = loadObject[ T](filename)
