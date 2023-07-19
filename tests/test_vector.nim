import unittest
import nuancepkg/la/vector


test "vector creation and access":
  var v1 = Vector3f(arr: [1.0, 2.0, 3.0])
  let
    v2 = Vector3f(arr: [5.0, 2.0, 3.0])
    v3 = Vec3(5.0, 2.0, 3.0)

  check v1[0] == 1.0
  check v1[1] == 2.0
  check v1[2] == 3.0

  check v1.x == 1.0
  check v1.y == 2.0
  check v1.z == 3.0

  v1[0] = 5.0
  check v1[0] == 5.0

  check v1 == v2
  check v3 == v2

  v1.x = 7.0
  v1.y = 8.0
  v1.z = 9.0
  check v1 == Vec3(7.0, 8.0, 9.0)
  v1.x += 1.0
  check v1 == Vec3(8.0, 8.0, 9.0)
  v1.z -= 1.0
  check v1 == Vec3(8.0, 8.0, 8.0)


test "vector componentwise maths":
  let
    v1 = Vector3f(arr: [1.0, 2.0, 3.0])
    v2 = Vector3f(arr: [4.0, 5.0, 6.0])

  let v3: Vector3f = v1 + v2
  check v3 == Vector3f(arr: [5.0, 7.0, 9.0])

  let v4: Vector3f = v1 - v2
  check v4 == Vector3f(arr: [-3.0, -3.0, -3.0])

  let v5: Vector3f = v1 * v2
  check v5 == Vector3f(arr: [1.0*4.0, 2.0*5.0, 3.0*6.0])

  let v6 = v1 / v2;
  check v6 == Vector3f(arr: [1.0/4.0, 2.0/5.0, 3.0/6.0])


test "vector scalar multiplication / division":
  let
    v1 = Vector3f(arr: [1.0, 2.0, 3.0])
    v2 = Vector3f(arr: [2.0, 4.0, 6.0])
  check 2.0 * v1 == v2
  check v1 * 2.0 == v2
  check v2 / 2.0 == v1

  var
    v3 = Vector3f(arr: [1.0, 2.0, 3.0])

  v3 *= 2.0
  check v3 == v2


test "dot product":
  let
    v1 = Vector3f(arr: [1.0, 2.0, 3.0])
    v2 = Vector3f(arr: [2.0, 4.0, 6.0])
    v3 = Vector3f(arr: [-1.0, -1.0, -1.0])

  check dot(v1, v2) == 2.0 + 8.0 + 18.0
  check v1*.v2 == 2.0 + 8.0 + 18.0

  check absdot(v1, v3) == 1.0 + 2.0 + 3.0


test "vector length":
  let
    v1 = Vector3f(arr: [1.0, 0.0, 0.0])
    v2 = Vector3f(arr: [3.0, 4.0, 0.0])

  check length(v1) == 1.0
  check length(v2) == 5.0
  check length_squared(v2) == 25.0
  let n2 = norm(v2)
  check n2 == Vector3f(arr: [3.0/5.0, 4.0/5.0, 0.0])
  check length(n2) == 1.0


test "cross product":
  let
    v1 = Vector3f(arr: [3.0, -3.0, 1.0])
    v2 = Vector3f(arr: [4.0, 9.0, 2.0])

  check cross(v1, v2) == Vector3f(arr: [-15.0, -2.0, 39.0])
  check cross(v1, v2) == v1*^v2


test "misc utilities":
  let
    v1 = Vector3f(arr: [3.0, -3.0, 1.0])
    v2 = Vector3f(arr: [4.0, 9.0, 2.0])
    v3 = Vector3f(arr: [3.5, 10.0, -2.0])

  check min_cpt(v1) == -3.0
  check max_cpt(v1) == 3.0
  check min_cpt(v2) == 2.0
  check max_cpt(v2) == 9.0

  check min(v1, v2) == Vector3f(arr:[3.0, -3.0, 1.0])
  check max(v1, v2) == Vector3f(arr:[4.0, 9.0, 2.0])
  check min(v1, v3) == Vector3f(arr:[3.0, -3.0, -2.0])
  check max(v1, v3) == Vector3f(arr:[3.5, 10.0, 1.0])
  check min(v2, v3) == Vector3f(arr:[3.5, 9.0, -2.0])
  check max(v2, v3) == Vector3f(arr:[4.0, 10.0, 2.0])

  check max_dim(v1) == 0
  check max_dim(v2) == 1

  check permute(v1, [2, 0, 1]) == Vector3f(arr:[1.0, 3.0, -3.0])

  var v4 = Vector3f(arr: [3.0, -3.0, 1.0])
  mut_permute(v4, [0, 2, 1])
  check v4 == Vector3f(arr:[3.0, 1.0, -3.0])
  mut_permute(v4, [2, 0, 1])
  check v4 == Vector3f(arr:[-3.0, 3.0, 1.0])

  echo refract(Vec3(1.0, 0.0, 0.0), norm(Vec3(-1.0, 1.0, 0.0)), 1.0)



