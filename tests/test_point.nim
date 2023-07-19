import unittest
import nuancepkg/la/point
import nuancepkg/la/vector


test "point creation and access":
  var p1 = Point3f(arr: [1.0, 2.0, 3.0])
  let
    p2 = Point3f(arr: [5.0, 2.0, 3.0])
    p3 = Pt3(5.0, 2.0, 3.0)

  check p1[0] == 1.0
  check p1[1] == 2.0
  check p1[2] == 3.0

  check p1.x == 1.0
  check p1.y == 2.0
  check p1.z == 3.0

  p1[0] = 5.0
  check p1[0] == 5.0

  check p1 == p2
  check p3 == p2

  p1.x = 7.0
  p1.y = 8.0
  p1.z = 9.0
  check p1 == Pt3(7.0, 8.0, 9.0)
  p1.x += 1.0
  check p1 == Pt3(8.0, 8.0, 9.0)
  p1.z -= 1.0
  check p1 == Pt3(8.0, 8.0, 8.0)


test "distances":
  let
    p1 = Pt3(0.0, 0.0, 3.0)
    p2 = Pt3(0.0, 4.0, 0.0)

  check distance(p1, p2) == 5.0
  check distanceSquared(p1, p2) == 25.0


test "linear interpolation":
  let
    p1 = Pt3(0.0, 0.0, 0.0)
    p2 = Pt3(1.0, 1.0, 1.0)
    p3 = Pt3(1.0, 2.0, 0.0)

  check linearInterp(0.1, p1, p2) == Pt3(0.1, 0.1, 0.1)
  check linearInterp(0.5, p1, p2) == Pt3(0.5, 0.5, 0.5)
  check linearInterp(0.99, p1, p2) == Pt3(0.99, 0.99, 0.99)

  check linearInterp(0.1, p1, p3) == Pt3(0.1, 0.2, 0.0)
  check linearInterp(0.5, p1, p3) == Pt3(0.5, 1.0, 0.0)
  check linearInterp(0.99, p1, p3) == Pt3(0.99, 0.99*2.0, 0.0)


test "vector floor, ceil, abs":
  let
    p1 = Pt3(0.5, 2.7, 3.1)
    p2 = Pt3(1.5, -2.5, -3.6)

  check floor(p1) == Pt3(0.0, 2.0, 3.0)
  check ceil(p1) == Pt3(1.0, 3.0, 4.0)
  check abs(p2) == Pt3(1.5, 2.5, 3.6)
