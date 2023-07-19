import unittest
import nuancepkg/la/matrix
import nuancepkg/la/transform
import nuancepkg/la/vector
import nuancepkg/la/point
import nuancepkg/la/bounds


test "matrix multiplication":
  let
    m1 = Matrix[2, 3, float](arr: [[1.0, 2.0, -1.0], [2.0, 0.0, 1.0]])
    m2 = Matrix[3, 2, float](arr: [[3.0, 1.0], [0.0, -1.0], [-2.0, 3.0]])
    m3 = Matrix[2, 2, float](arr: [[5.0, -4.0], [4.0, 5.0]])
  check (m1 * m2) == m3


test "transform point":
  let
    p1 = Pt3(1.0, 2.0, 3.0)
    p2 = Pt3(0.0, 1.0, 0.0)
    s = Scale(Vec3(1.0, 2.0, 3.0))
    t = Translate(Vec3(5.0, 4.0, 7.0))
    r = RotateX(90.0)

  check s(p1) == Pt3(1.0, 4.0, 9.0)
  check t(p1) == Pt3(6.0, 6.0, 10.0)
  check r(p2) ~= Pt3(0.0, 0.0, 1.0)

  check (inverse(s) * s).m == Identity[4, 4, float]()
  check (inverse(t) * t).m == Identity[4, 4, float]()
  check (inverse(r) * r).m == Identity[4, 4, float]()
  let trans = s * t
  check trans(p1) == Pt3(6.0, 12.0, 30.0)


test "transform vector":
  let
    v1 = Vec3(1.0, 2.0, 3.0)
    s = Scale(Vec3(1.0, 2.0, 3.0))
    t = Translate(Vec3(5.0, 4.0, 7.0))

  check s(v1) == Vec3(1.0, 4.0, 9.0)
  check t(v1) == v1


test "arbitrary rotation":
  let
    angles = [0.0, 25.0, 45.0, 60.0, 79.0, 90.0, 150.0, 275.0]

  for angle in angles:
    check Rotate(angle, Vec3(1.0, 0.0, 0.0)).m ~= RotateX(angle).m
    check Rotate(angle, Vec3(0.0, 1.0, 0.0)).m ~= RotateY(angle).m
    check Rotate(angle, Vec3(0.0, 0.0, 1.0)).m ~= RotateZ(angle).m

test "transform bounds":
  let
    b1 = newBounds(Pt3(0.0, 0.0, 0.0), Pt3(1.0, 1.0, 1.0))
    b2 = newBounds(Pt3(0.0, 0.0, 0.0), Pt3(1.0, 2.0, 3.0))
    s = Scale(Vec3(1.0, 2.0, 3.0))

  let b3 = s(b1)
  check b3 == b2
