
# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest, sim

type
  Student = object
    name: string
    age: int

  Course = object
    name: string
    year: int
    students: seq[Student]

suite "parse ini":
  var cfg = to[Course]("tests/config2.ini")

  test "top level":
    assert cfg.name == "Nim 101"
    assert cfg.year == 2019

  test "seq of objects":
    assert cfg.students.len == 2
    assert cfg.students[0].name == "John"
    assert cfg.students[0].age == 18
    assert cfg.students[1].name == "Peter"
    assert cfg.students[1].age == 20
