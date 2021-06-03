import unittest, sim

type
  Server = object
    address: string
    port: int
  Config = object
    server: Server

suite "parse ini":
  var cfg = loadObject[Config]("tests/config6.ini")

  test "wildcard seq":
    assert cfg.server.address == "127.0.0.1"
    assert cfg.server.port == 5000