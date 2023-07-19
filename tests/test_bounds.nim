import unittest
import nuancepkg/la/bounds
import nuancepkg/la/point
import nuancepkg/la/vector

suite "test bounds":
  test "bounds init":
    let
      p1 = Pt3(1.0, 0.0, 2.0)
      p2 = Pt3(-1.0, 1.0, 3.0)

    let b2 = newBounds(p1, p2)

    check b2.pMin == Pt3(-1.0, 0.0, 2.0)
    check b2.pMax == Pt3(1.0, 1.0, 3.0)


  test "bounds corner":
    let
      b1 = newBounds(Pt3(0.0, 0.0, 0.0), Pt3(1.0, 1.0, 1.0))

    check corner(b1, 0) == Pt3(0.0, 0.0, 0.0)
    check corner(b1, 1) == Pt3(1.0, 0.0, 0.0)
    check corner(b1, 2) == Pt3(0.0, 1.0, 0.0)
    check corner(b1, 3) == Pt3(1.0, 1.0, 0.0)
    check corner(b1, 4) == Pt3(0.0, 0.0, 1.0)
    check corner(b1, 5) == Pt3(1.0, 0.0, 1.0)
    check corner(b1, 6) == Pt3(0.0, 1.0, 1.0)
    check corner(b1, 7) == Pt3(1.0, 1.0, 1.0)


  test "bounds union":
    let
      b1 = newBounds(Pt3(0.0, 0.0, 0.0))
      p1 = Pt3(1.0, 1.0, 1.0)
      p2 = Pt3(3.0, 0.0, 0.0)

    let b2 = union(b1, p1)

    check b2.pMin == Pt3(0.0, 0.0, 0.0)
    check b2.pMax == Pt3(1.0, 1.0, 1.0)

    let b3 = union(b2, p2)

    check b3.pMin == Pt3(0.0, 0.0, 0.0)
    check b3.pMax == Pt3(3.0, 1.0, 1.0)


  test "bounds intersection":
    let
      b1 = newBounds(Pt3(0.0, 0.0, 0.0))
      b2 = newBounds(Pt3(0.0, 0.0, 0.0), Pt3(2.0, 1.0, 0.0))
      b3 = newBounds(Pt3(0.0, 0.0, 0.0), Pt3(1.0, 2.0, 0.0))
      b4 = newBounds(Pt3(0.0, 0.0, 0.0), Pt3(1.0, 1.0, 0.0))

    check intersect(b1, b2) == b1
    check intersect(b1, b3) == b1
    check intersect(b2, b3) == b4


  test "bounds overlap":
    let
      b1 = newBounds(Pt3(0.0, 0.0, 0.0), Pt3(1.0, 1.0, 0.0))

      b2 = newBounds(Pt3(0.0, 0.0, 0.0), Pt3(0.5, 5.0, 0.0))
      b3 = newBounds(Pt3(0.0, 0.0, 0.0), Pt3(1.5, 0.1, 0.0))

      b4 = newBounds(Pt3(1.1, 1.1, 0.0), Pt3(2.0, 2.0, 0.0))

    check overlaps(b1, b2)
    check overlaps(b1, b3)
    check overlaps(b1, b4) == false


  test "inside":
    let
      b1 = newBounds(Pt3(0.0, 0.0, 0.0), Pt3(1.0, 1.0, 0.0))

    check inside(b1, Pt3(1.0, 1.0, 0.0))
    check inside(b1, Pt3(0.5, 0.5, 0.0))
    check inside(b1, Pt3(0.2, 1.0, 0.0))
    check inside(b1, Pt3(0.0, 1.0, 0.0))

    check inside(b1, Pt3(0.0, 1.1, 0.0)) == false
    check inside(b1, Pt3(0.5, 0.5, 1.0)) == false


  test "bounds expand":
    let
      b1 = newBounds(Pt3(0.0, 0.0, 0.0))

    let b2 = expand(b1, 1.0)
    check b2 == newBounds(Pt3(-1.0, -1.0, -1.0), Pt3(1.0, 1.0, 1.0))


  test "bounds expand":
    let
      b1 = newBounds(Pt3(0.0, 0.0, 0.0), Pt3(1.0, 2.0, 3.0))

    check diagonal(b1) == Vec3(1.0, 2.0, 3.0)
