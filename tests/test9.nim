import unittest, sim

type
  Gender = enum
    F
    M

  Person = object
    fname: string
    lname: string
    age: int
    gender: Gender

  Config = object
    dad: Person
    mom: Person
    children: seq[Person]

suite "parse ini":
  var cfg = loadObject[Config]("tests/config9.ini")

  test "inheritance":
    assert cfg.children.len == 4

    assert cfg.dad.fname == "William"
    assert cfg.dad.lname == "Smith"
    assert cfg.dad.age == 34
    assert cfg.dad.gender == M

    assert cfg.mom.fname == "Sophia"
    assert cfg.mom.lname == "Smith"
    assert cfg.mom.age == 32
    assert cfg.mom.gender == F

    assert cfg.children[0].fname == "Bob"
    assert cfg.children[0].lname == "Smith"
    assert cfg.children[0].age == 11
    assert cfg.children[0].gender == M

    assert cfg.children[1].fname == "John"
    assert cfg.children[1].lname == "Smith"
    assert cfg.children[1].age == 11
    assert cfg.children[1].gender == M

    assert cfg.children[2].fname == "Emma"
    assert cfg.children[2].lname == "Smith"
    assert cfg.children[2].age == 1
    assert cfg.children[2].gender == F

    assert cfg.children[3].fname == "Mia"
    assert cfg.children[3].lname == "Smith"
    assert cfg.children[3].age == 4
    assert cfg.children[3].gender == F
