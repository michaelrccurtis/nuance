import unittest
import nuance/collisions/collisions
import nuance/collisions/bounds as bounds_collision
import nuance/la/bounds
import nuance/la/ray
import nuance/la/point
import nuance/la/vector

test "ray -> bounds collision":
  let
    r1 = Ray3(Pt3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0))
    b1 = new_bounds(Pt3(0.0, 0.0, 0.0), Pt3(1.0, 1.0, 1.0))
