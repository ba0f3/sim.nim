import unittest, sim, marshal, json

type
  Batter = object
    id: string
    kind: string
  Topping = object
    id: string
    kind: string

  Batters = object
    batter: seq[Batter]

  Dataset = object
    id: string
    kind: string
    name: string
    ppu: float
    batters: Batters
    topping: seq[Topping]

proc parseData(input: string): Dataset =
  result = marshal.to[Dataset](input)

proc parseIntSeq(input: string): seq[int] =
  let node = parseJson(input)
  assert node.kind == JArray
  for n in node:
    result.add n.getInt

type
  InnerObj = object
    data {.parseHook: parseIntSeq.}: seq[int]
  Config = object
    dataset {.parseHook: parseData.}: Dataset
    innerObj: InnerObj

suite "parse ini":
  var cfg: Config
  test "test parseHook":
    cfg = loadObject[Config]("tests/test11.ini")
  test "test dataset":
    assert cfg.dataset.id == "0001"
    assert cfg.dataset.kind == "donut"
    assert cfg.dataset.name == "Cake"
    assert cfg.dataset.ppu == 0.55
    assert cfg.dataset.batters.batter.len == 4
    assert cfg.dataset.batters.batter[0].id == "1001"
    assert cfg.dataset.batters.batter[0].kind == "Regular"
    assert cfg.dataset.topping.len == 7
    assert cfg.dataset.topping[1].id == "5002"
    assert cfg.dataset.topping[1].kind == "Glazed"

  test "inner object":
    assert cfg.innerObj.data == @[1,3,4,5,6]

