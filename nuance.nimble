# Package

version       = "0.0.1"
author        = "Mike Curtis"
description   = "A path tracer for nim!"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["nuance"]
binDir        = "bin"

# Dependencies
requires "nim >= 1.6.6"
requires "simplepng"
requires "cligen"
requires "toml_serialization"
requires "malebolgia"

import os
import std/strformat


task cleantests, "Clean test binaries":
  for test in walkDir("./tests"):
    if test.kind == pcFile:
      let splittedFile = splitFile(test.path)
      if splittedFile.ext == "":
        echo "Removing ", test.path
        exec fmt"rm {test.path}"


task format, "Format the source code":
  exec "nimpretty --maxLineLen:120 --indent:4 src/nuancepkg/**/*.nim"

task benchmark, "Run benchmarks":
  exec "nim c --run  utils/benchmark.nim"