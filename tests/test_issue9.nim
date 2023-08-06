import unittest, sim, streams

type
  Tables = enum
    Table1
    Table2

  Config* = object
    csvtables: seq[Tables]

suite "parse section keys as enum":
  let input = newStringStream("""
[csvtables]
# List all the tables you want to download as csv here.
# This section is ignored when you disable downloadCSV
Table1
Table2
""")

  var cfg = loadObject[Config](input)

  test "enum":
    assert cfg.csvtables[0] == Table1
    assert cfg.csvtables[1] == Table2