import unittest, sim

type
  Student = object
    name: string
    age: int
  Config = object
    students: seq[Student]

suite "parse ini":
  var cfg = loadObject[Config]("tests/config5.ini")

  test "wildcard seq":
    assert cfg.students.len == 2
    assert cfg.students[0].name == "John Doe"
    assert cfg.students[0].age == 19
    assert cfg.students[1].name == "Peter Pan"
    assert cfg.students[1].age == 20
