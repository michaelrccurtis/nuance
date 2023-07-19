import unittest
import nuancepkg/shape/shape
import nuancepkg/shape/cylinder
import nuancepkg/collisions/collisions
import nuancepkg/collisions/cylinder as cylinder_collisions
import nuancepkg/la/vector
import nuancepkg/la/ray
import nuancepkg/la/point
import nuancepkg/la/transform


test "cylinder collisions":
  let
    r1 = new_ray(Pt3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0))

  check Cylinder.make(1.0, 0.0, 1.0, Translate(Vec3(2.0, 0.0, 0.0))).collides(r1)
  check not Cylinder.make(1.0, 0.0, 1.0, Translate(Vec3(-2.0, 0.0, 0.0))).collides(r1)
