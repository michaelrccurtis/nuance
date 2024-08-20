import unittest
import nuance/la/point
import nuance/la/vector
import nuance/la/normal
import nuance/la/transform
import nuance/la/bounds
import nuance/la/ray
import nuance/shape/triangle_mesh
import nuance/shape/triangle
import nuance/collisions/collisions
import nuance/collisions/triangle as triangle_collisions

test "triangle collisions":
  let
    mesh = TriangleMesh[float].init(
      Translate(Vec3(0.0, 0.0, -1.0)),
      [0, 1, 2],
      [Pt3(0.0, 0.0, 0.0), Pt3(1.0, 0.0, 0.0), Pt3(0.0, 1.0, 0.0)]
    )
    tri = Triangle[float].make(
      Translate(Vec3(0.0, 0.0, -1.0)),
      mesh,
      0
    )
    r1 = new_ray(Pt3(0.1, 0.1, 0.0), Vec3(0.0, 0.0, -1.0))

  check collides(tri, r1)
  let col = get_collisions(tri, r1)
  echo col
