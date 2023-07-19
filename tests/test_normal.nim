import unittest
import nuancepkg/la/normal
import nuancepkg/la/vector


template notCompiles*(e: untyped): untyped =
  not compiles(e)


test "normal creation and access":
  var n1 = Norm3(1.0, 2.0, 3.0)

  n1.x = 7.0
  n1.y = 8.0
  n1.z = 9.0
  check n1 == Norm3(7.0, 8.0, 9.0)


test "normal no cross product":
  var n1 = Norm3(1.0, 2.0, 3.0)
  check:
    notCompiles: 
      let x = n1 *^ n1

test "faceforward":
  var 
    n1 = Norm3(-1.0, 0.0, 0.0)
    v1 = Vec3(1.0, 0.0, 0.0)

  check faceforward(n1, v1) == Norm3(1.0, 0.0, 0.0)
