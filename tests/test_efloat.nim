import unittest
import nuancepkg/math/efloat
import nuancepkg/math/fp
import nuancepkg/math/quadratic

test "float to bits":
  let
    floats = [
      1.0, -5.0, 99.46225
    ]
    fltInf = 1.0 / 0.0
    fltNegInf = -1.0 / 0.0

  for flt in floats:
    check bitsToFloat(floatToBits(flt)) == flt
    check nextFloatUp(flt) > flt
    check nextFloatDown(flt) < flt

  check nextFloatUp(fltInf) == fltInf
  check nextFloatDown(fltNegInf) == fltNegInf

test "quadratic solver":
  check quadraticSolvable(5.0, 6.0, 1.0)
  check not quadraticSolvable(5.0, 2.0, 1.0)

  let solutions = quadratic(5.0, 6.0, 1.0)
  check solutions[0] == -1.0
  check solutions[1] == -0.2

test "efloat":
  let
    x = efloat(1.0)
    y = efloat(1.0)

  check x == y
  check (x + y).v == 2.0
  echo x
  echo x + y