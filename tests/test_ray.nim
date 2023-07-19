import unittest
import nuancepkg/la/point
import nuancepkg/la/vector
import nuancepkg/la/ray


test "ray creation and interpolation":
  let
    r1 = Ray3(Pt3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0))
    r2 = Ray3(Pt3(1.0, 2.0, 3.0), Vec3(3.0, 2.0, 1.0))

  check r1(0.5) == Pt3(0.5, 0.0, 0.0)
  check r2(0.0) == Pt3(1.0, 2.0, 3.0)
  check r2(1.0) == Pt3(4.0, 4.0, 4.0)
  check r2(2.0) == Pt3(7.0, 6.0, 5.0)

  let rd1 = RayD3(r1)

  check rd1.hasDifferentials == false
  check rd1(0.5) == Pt3(0.5, 0.0, 0.0)


test "scale differentials":
  let rd1 = RayDifferential[3, float]()
  rd1.hasDifferentials = true
  rd1.o = Pt3(0.0, 0.0, 0.0)
  rd1.d = Vec3(1.0, 0.0, 0.0)

  rd1.rxOrigin = Pt3(0.0, 1.0, 0.0)
  rd1.ryOrigin = Pt3(0.0, 0.0, 1.0)
  rd1.rxDirection = Vec3(1.0, 0.0, 0.0)
  rd1.ryDirection = Vec3(1.0, 0.0, 0.0)

  rd1.scaleDifferentials(2.0)

  check rd1.rxOrigin == Pt3(0.0, 2.0, 0.0)
  check rd1.ryOrigin == Pt3(0.0, 0.0, 2.0)
