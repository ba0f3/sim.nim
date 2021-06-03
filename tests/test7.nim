import unittest, sim

type
  Level2 = object
    foobaz: string
  Sub = object
    foobaz: string
    level2: Level2
  Main = object
    foo: string
    baz: string
    sub: Sub
  Config = object
    main: Main

suite "parse ini":
  var cfg = loadObject[Config]("tests/config7.ini")

  test "nested objects":
    assert cfg.main.foo == "foo"
    assert cfg.main.baz == "baz"
    assert cfg.main.sub.foobaz == "foobaz"
    assert cfg.main.sub.level2.foobaz == "foobaz2"