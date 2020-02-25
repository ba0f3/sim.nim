import unittest, sim

type
  Config = object
    binDir: string
    etcDir {.value: "/etc".}: string
    tmpDir {.value: "/tmp".}: string

suite "parse ini":
  var cfg = to[Config]("tests/config4.ini")

  test "empty default value":
    assert cfg.binDir == "/bin"
    assert cfg.etcDir == "/etc"
    assert cfg.tmpDir == "/tmp"
