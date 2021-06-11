import unittest, sim

type
  GuiConfig* = object
    window_title*: string
    window_width* {.defaultValue: 1024.}: int32
    window_height* {.defaultValue:  400.}: int32

  Config* = object
    file* {.defaultValue: "file.bin".}: string
    gui*: GuiConfig

suite "parse ini":
  var cfg = loadObject[Config]("tests/test_issue4.ini")

  test "top level":
    assert cfg.file == "file.bin"

  test "inner object":
    assert cfg.gui.window_title == "My first window"
    assert cfg.gui.window_width == 1024
    assert cfg.gui.window_height == 400
