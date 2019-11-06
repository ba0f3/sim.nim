# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest, sim


type
  BoolObject = object
    boolOn: bool
    boolTrue: bool
    boolOff: bool
    boolFalse: bool

  Config = object
    intVal: int
    uintVal: uint
    boolTrue: bool
    boolFalse: bool
    strVal: string
    floatVal: float
    intSeq: seq[int]
    stringAsBool: BoolObject

suite "parse ini":
  var cfg = to[Config]("tests/config1.ini")

  test "parse number":
    assert cfg.intVal == -123456
    assert cfg.uintVal == 2019
  test "parse bool":
    assert cfg.boolTrue == true
    assert cfg.boolFalse == false
  test "parse string":
    assert cfg.strVal == "hello world"
  test "parse float":
    assert cfg.floatVal == 3.15
  test "parse int seq":
    assert cfg.intSeq == @[1,2,3]
  test "parse nested object":
    assert cfg.stringAsBool.boolOn == true
    assert cfg.stringAsBool.boolOff == false
    assert cfg.stringAsBool.boolTrue == true
    assert cfg.stringAsBool.boolFalse == false
