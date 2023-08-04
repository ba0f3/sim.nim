# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest, sim


type
  Downloads = object
    downloadXLSX: bool

  Config = object
    downloads: Downloads

suite "parse ini":
  test "raise exception for invalid bool value":
    expect InvalidValueException:
      var cfg = loadObject[Config]("tests/config13.ini", useSnakeCase=false)
      echo cfg