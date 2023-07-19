import unittest
import nuancepkg/shape/shape
import nuancepkg/shape/sphere
import nuancepkg/collisions/collisions
import nuancepkg/collisions/sphere as sphere_collisions
import nuancepkg/la/all


test "sphere collisions":
  let
    r1 = new_ray(Pt3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0))

  # collide
  check Sphere.make(1.0, Translate(Vec3(2.0, 0.0, 0.0))).collides(r1)
  check Sphere.make(1.0, Translate(Vec3(50.0, 0.0, 0.0))).collides(r1)
  check Sphere.make(1.0, Translate(Vec3(2.0, 0.99, 0.0))).collides(r1)
  check Sphere.make(1.0, Translate(Vec3(2.0, -0.5, 0.0))).collides(r1)

  # don't collide
  check not Sphere.make(1.0, Translate(Vec3(2.0, 1.1, 0.0))).collides(r1)
  check not Sphere.make(1.0, Translate(Vec3(-2.0, 0.0, 0.0))).collides(r1)
  check not Sphere.make(1.0, Translate(Vec3(-20.0, 0.0, 0.0))).collides(r1)
  check not Sphere.make(1.0, Translate(Vec3(2.0, 0.0, 2.0))).collides(r1)

  let
    r2 = new_ray(Pt3(-2.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0))
    sp = Sphere.make(1.0, Translate(Vec3(0.0, 0.0, 0.0)))
    col = get_collisions(sp, r2)
  
  echo "n=", col.interaction.n, " p=",col.interaction.p