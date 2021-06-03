import unittest, sim

type
  Config = object
    binDir: string
    etcDir {.defaultValue: "/etc".}: string
    tmpDir {.defaultValue: "/tmp".}: string
    optDir {.ignore.}: string
suite "parse ini":
  var cfg = loadObject[Config]("tests/config4.ini")

  test "empty default value":
    assert cfg.binDir == "/bin"
    assert cfg.etcDir == "/etc"
    assert cfg.tmpDir == "/tmp"
