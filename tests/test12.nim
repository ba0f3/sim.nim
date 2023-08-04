import unittest, sim

type
  Config = object
    binDir: string
    etcDir {.defaultValue: "/etc".}: string
    tmpDir {.defaultValue: "/tmp".}: string
    optDir {.ignore.}: string

suite "parse ini":
  var cfg = loadObject[Config]("tests/config12.ini", useSnakeCase=false)

  test "dont use snake_case":
    assert cfg.binDir == "/bin"
    assert cfg.etcDir == "/etc"
    assert cfg.tmpDir == "/tmp"
