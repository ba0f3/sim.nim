
# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest, sim

type
  Config = object
    emptySeq: seq[int]
    emptyItemSeq1: seq[int]
    emptyItemSeq2: seq[int]
    emptyItemSeq3: seq[int]
    emptyStringItemSeq: seq[string]
suite "parse ini":
  var cfg = to[Config]("tests/config3.ini")

  test "empty seq":
    assert cfg.emptySeq.len == 0
  test "empty item":
    assert cfg.emptyItemSeq1.len == 0
    assert cfg.emptyItemSeq2.len == 1
    assert cfg.emptyItemSeq3.len == 2
  test "empty string item":
    assert cfg.emptyStringItemSeq.len == 3
