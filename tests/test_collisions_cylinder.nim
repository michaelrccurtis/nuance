import unittest
import nuance/shape/shape
import nuance/shape/cylinder
import nuance/collisions/collisions
import nuance/collisions/cylinder as cylinder_collisions
import nuance/la/vector
import nuance/la/ray
import nuance/la/point
import nuance/la/transform


test "cylinder collisions":
  let
    r1 = new_ray(Pt3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0))

  check Cylinder.make(1.0, 0.0, 1.0, Translate(Vec3(2.0, 0.0, 0.0))).collides(r1)
  check not Cylinder.make(1.0, 0.0, 1.0, Translate(Vec3(-2.0, 0.0, 0.0))).collides(r1)
