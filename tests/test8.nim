import unittest, sim

type
  Config = object
    data: string

suite "parse ini":
  test "empty ini file still works and gives meningful exception":
    try:
      var cfg = loadObject[Config]("tests/config8.ini")
    except KeyNotFoundException as e:
      assert e.msg == "Key `data` not found in top level section"
