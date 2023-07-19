import unittest
import nuancepkg/collisions/collisions
import nuancepkg/collisions/bounds as bounds_collision
import nuancepkg/la/bounds
import nuancepkg/la/ray
import nuancepkg/la/point
import nuancepkg/la/vector

test "ray -> bounds collision":
  let
    r1 = Ray3(Pt3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0))
    b1 = new_bounds(Pt3(0.0, 0.0, 0.0), Pt3(1.0, 1.0, 1.0))
