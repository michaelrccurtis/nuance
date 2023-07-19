import unittest
import nuancepkg/la/matrix

test "matrix invert":
  let
    mat1 = Matrix[2, 2, float](arr: [
      [4.0, 7.0],
      [2.0, 6.0],
    ])
    mat2 = Matrix[3, 3, float](arr: [
      [5.0, 7.0, 9.0],
      [4.0, 3.0, 8.0],
      [7.0, 5.0, 6.0]
    ])

  check inverse(mat1) * mat1 ~= Identity[2, 2, float]()
  check mat1 * inverse(mat1) ~= Identity[2, 2, float]()

  check inverse(mat2) * mat2 ~= Identity[3, 3, float]()
  check mat2 * inverse(mat2) ~= Identity[3, 3, float]()
