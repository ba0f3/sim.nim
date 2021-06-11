import unittest, sim

type
  Box* = object
    w*: int32
    h*: int32
  Config = object
    box {.defaultValue: Box(w: 6, h: 4).}: Box

suite "parse ini":
  test "default value for object":
    var cfg = loadObject[Config]("tests/empty.ini")
    assert cfg.box.w == 6
    assert cfg.box.h == 4

