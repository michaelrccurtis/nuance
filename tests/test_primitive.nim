import unittest
import nuancepkg/scene/all
import nuancepkg/shape/all
import nuancepkg/la/all
import nuancepkg/collisions/all

test "geometric primitive":

  let
    sphere = Sphere.make(1.0, Translate(Vec3(0.0, 0.0, 0.0)))
    prim = GeometricPrimitive[float](shape: sphere)
    r1 = new_ray(Pt3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0))

  check prim.world_bounds == sphere.world_bounds

  check GeometricPrimitive[float](
    shape: Sphere.make(1.0, Translate(Vec3(2.0, 0.0, 0.0)))
  ).collides(r1)

  check GeometricPrimitive[float](
    shape: Sphere.make(1.0, Translate(Vec3(50.0, 0.0, 0.0)))
  ).collides(r1)

  check GeometricPrimitive[float](
    shape: Sphere.make(1.0, Translate(Vec3(2.0, 0.99, 0.0)))
  ).collides(r1)

  check GeometricPrimitive[float](
    shape: Sphere.make(1.0, Translate(Vec3(2.0, -0.5, 0.0)))
  ).collides(r1)

  # don't collide
  check not GeometricPrimitive[float](
    shape: Sphere.make(1.0, Translate(Vec3(2.0, 1.1, 0.0)))
  ).collides(r1)
  check not GeometricPrimitive[float](
    shape: Sphere.make(1.0, Translate(Vec3(-2.0, 0.0, 0.0)))
  ).collides(r1)
  check not GeometricPrimitive[float](
    shape: Sphere.make(1.0, Translate(Vec3(-20.0, 0.0, 0.0)))
  ).collides(r1)
  check not GeometricPrimitive[float](
    shape: Sphere.make(1.0, Translate(Vec3(2.0, 0.0, 2.0)))
  ).collides(r1)


test "naive primitive group":
  let 
    sphere1 = Sphere.make(1.0, Translate(Vec3(2.0, 0.0, 0.0)))
    sphere2 = Sphere.make(1.0, Translate(Vec3(10.0, 0.0, 0.0)))
    prim = newGroup( 
      @[GeometricPrimitive[float](shape: sphere1), GeometricPrimitive[float](shape: sphere2)]
    )

  check prim.collides(new_ray(Pt3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0))).collides
  check prim.collides(new_ray(Pt3(1.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0))).collides
