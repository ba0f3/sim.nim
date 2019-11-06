Sim
-------

Sim is an utility that helps you convert a config file (only ini file supported atm) by define an object

Supported types:
- int64/uint64/int32/uin32/int16/uint16/int8/uint8
- float
- char
- bool (value can be string like on/off, true/false, and numbers. number less than 1 treated as `false`)
- string
- nested object
- seq (seq of those type above)

**NOTE: config sections and keys must use snake case**

you can define a field with seq of objects, each object has itsown section in config. the key name of `seq` is the list of objects' name, for example:
```ini
students = "student1,student2"
[student1]
name = John
[student2]
name = Peter
```

### Why the name is Sim?
I named it as my third daughter (nothing special for you, ofcourse)


Installation
------------

```shell
nimble  install sim
```

Usage
-----
config.ini:
```ini
name = "Nim 101"
year = 2019
students = "student1,student2"

[student1]
name = John
age = 18
[student2]
name = Peter
age = 20
```
foo.nim:
```nim
import sim

type
  Student = object
    name: string
    age: int

  Course = object
    name: string
    year: int
    students: seq[Student]

var cfg = to[Course]("config.ini")
echo &"Welcome to `{cfg.name}`, we have cfg.students.len} students registered"
```

Donate
-----

Buy me some beer https://paypal.me/ba0f3