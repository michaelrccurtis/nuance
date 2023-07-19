import unittest
import nuancepkg/la/point
import nuancepkg/la/vector
import nuancepkg/la/normal
import nuancepkg/la/transform
import nuancepkg/la/bounds
import nuancepkg/la/ray
import nuancepkg/shape/triangle_mesh
import nuancepkg/shape/triangle
import nuancepkg/collisions/collisions
import nuancepkg/collisions/triangle as triangle_collisions

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
