import math
import nuancepkg/math/fp
import shared_vector
import matrix
import vector
import point
import normal
import ray
import bounds

{.experimental: "callOperator".}

type Transform*[R, C: static[int], S: Scalar] = ref object
    m*: Matrix[R, C, S]
    m_inv*: Matrix[R, C, S]

proc `$`*[R, C, S](trans: Transform[R, C, S]): string =
    "->\n" & $trans.m & "\n<-\n" & $trans.m_inv

proc new_transform*[R, C, S](mat: Matrix[R, C, S]): Transform[R, C, S] =
    Transform[R, C, S](m: mat, m_inv: inverse(mat))

proc inverse*[R, C, S](trans: Transform[R, C, S]): Transform[R, C, S] =
    Transform[R, C, S](m: trans.m_inv, m_inv: trans.m)

proc transpose*[R, C, S](trans: Transform[R, C, S]): Transform[R, C, S] =
    Transform[R, C, S](m: transpose(trans.m), m_inv: transpose(trans.m_inv))

proc swaps_handedness*[R, C, S](trans: Transform[R, C, S]): bool =
    let det =
        trans.m[0][0] * (trans.m[1][1] * trans.m[2][2] - trans.m[1][2] * trans.m[2][1]) -
        trans.m[0][1] * (trans.m[1][0] * trans.m[2][2] - trans.m[1][2] * trans.m[2][0]) +
        trans.m[0][2] * (trans.m[1][0] * trans.m[2][1] - trans.m[1][1] * trans.m[2][0])
    return det < 0

# Specific Transform Constructors
proc NoTransform*[S](): Transform[4, 4, S] =
    result = Transform[4, 4, S](m: Identity[4, 4, S](), m_inv: Identity[4, 4, S]())

proc Translate*[S](delta: Vector[3, S]): Transform[4, 4, S] =
    var mat = Identity[4, 4, S]()
    var mat_inv = Identity[4, 4, S]()
    for idx in 0 ..< 3:
        mat[idx][3] = delta[idx]
        mat_inv[idx][3] = -delta[idx]
    result = Transform[4, 4, S](m: mat, m_inv: mat_inv)

proc Scale*[S](scale: Vector[3, S]): Transform[4, 4, S] =
    var mat = Identity[4, 4, S]()
    var mat_inv = Identity[4, 4, S]()
    for row in 0 ..< 3:
        for col in 0 ..< 3:
            mat[row][col] = if row == col: scale[row] else: S(0)
            mat_inv[row][col] = if row == col: S(1) / scale[row] else: S(0)
    result = Transform[4, 4, S](m: mat, m_inv: mat_inv)

proc RotateX*[S](theta: S): Transform[4, 4, S] =
    let sin_th = sin(deg_to_rad(theta))
    let cos_th = cos(deg_to_rad(theta))
    let mat = Matrix[4, 4, S](arr: [
      [S(1), S(0), S(0), S(0)],
      [S(0), cos_th, -sin_th, S(0)],
      [S(0), sin_th, cos_th, S(0)],
      [S(0), S(0), S(0), S(1)],
    ])
    result = Transform[4, 4, S](m: mat, m_inv: transpose(mat))

proc RotateY*[S](theta: S): Transform[4, 4, S] =
    let sin_th = sin(deg_to_rad(theta))
    let cos_th = cos(deg_to_rad(theta))
    let mat = Matrix[4, 4, S](arr: [
      [cos_th, S(0), sin_th, S(0)],
      [S(0), S(1), S(0), S(0)],
      [-sin_th, S(0), cos_th, S(0)],
      [S(0), S(0), S(0), S(1)],
    ])
    result = Transform[4, 4, S](m: mat, m_inv: transpose(mat))

proc RotateZ*[S](theta: S): Transform[4, 4, S] =
    let sin_th = sin(deg_to_rad(theta))
    let cos_th = cos(deg_to_rad(theta))
    let mat = Matrix[4, 4, S](arr: [
      [cos_th, -sin_th, S(0), S(0)],
      [sin_th, cos_th, S(0), S(0)],
      [S(0), S(0), S(1), S(0)],
      [S(0), S(0), S(0), S(1)],
    ])
    result = Transform[4, 4, S](m: mat, m_inv: transpose(mat))

proc rotation_formula*[S](vec: Vector[3, S], theta: S, axis: Vector[3, S]): Vector[3, S] =
    let ax = norm(axis)
    let sin_th = sin(deg_to_rad(theta))
    let cos_th = cos(deg_to_rad(theta))
    let vC = dot(vec, ax) * ax
    let v1 = vec - vC
    let v2 = v1 *^ ax
    return vC + v1 * cos_th + v2 * sin_th

proc Rotate*[S](theta: S, axis: Vector[3, S]): Transform[4, 4, S] =
    var mat = Identity[4, 4, S]()
    for idx in 0 ..< 3:
        let basis = OneHotVec[3, S](idx)
        let rotated = rotation_formula(basis, theta, axis)
        for jdx in 0 ..< 3:
            mat[idx][jdx] = rotated[jdx]
    result = Transform[4, 4, S](m: mat, m_inv: transpose(mat))

proc LookAt*[S](pos, look: Point[3, S], up: Vector[3, S]): Transform[4, 4, S] =
    var mat = Identity[4, 4, S]()

    let dir = norm(look - pos)
    let right = norm(norm(up) *^ dir)
    let new_up = dir *^ right

    for idx in 0 ..< 3:
        mat[idx][0] = right[idx]
        mat[idx][1] = new_up[idx]
        mat[idx][2] = dir[idx]
        mat[idx][3] = pos[idx]

    result = Transform[4, 4, S](m: inverse(mat), m_inv: mat)

proc Orthographic*[S](zNear, zFar: S): Transform[4, 4, S] =
    Scale(S(1), S(1), S(1) / (zFar - zNear)) * Translate(Vec3(S(0), S(0), -zNear))

proc Perspective*[S](fov, n, f: S): Transform[4, 4, S] =
    let
        mat = Matrix[4, 4, S](arr: [
          [S(1), S(0), S(0), S(0)],
          [S(0), S(1), S(0), S(0)],
          [S(0), S(0), f/(f-n), -f*n/(f-n)],
          [S(0), S(0), S(1), S(0)],
        ])
        invTanAng = S(1) / tan(deg_to_rad(fov) / S(2))
    return Scale(Vec3(invTanAng, invTanAng, S(1))) * new_transform(mat)

# Homogeneous Coordinates Transformations
# - Points
proc to_homogeneous*[D, S](pt: Point[D, S]): auto =
    result = Point[D+1, S]()
    for idx in 0 ..< D:
        result[idx] = pt[idx]
    result[D] = S(1)

proc from_homogeneous*[D, S](pt: Point[D, S]): auto =
    result = Point[D-1, S]()
    for idx in 0 ..< D-1:
        result[idx] = pt[idx] / pt[D-1]

# - Vectors
proc to_homogeneous*[D, S](vec: Vector[D, S]): auto =
    result = Vector[D+1, S]()
    for idx in 0 ..< D:
        result[idx] = vec[idx]
    result[D] = S(0)

proc from_homogeneous*[D, S](vec: Vector[D, S]): auto =
    result = Vector[D-1, S]()
    for idx in 0 ..< D-1:
        result[idx] = vec[idx]

# - Normals
proc to_homogeneous*[D, S](nrm: Normal[D, S]): auto =
    result = Normal[D+1, S]()
    for idx in 0 ..< D:
        result[idx] = nrm[idx]
    result[D] = S(0)

proc from_homogeneous*[D, S](nrm: Normal[D, S]): auto =
    result = Normal[D-1, S]()
    for idx in 0 ..< D-1:
        result[idx] = nrm[idx]

# Applying Transformations
proc `()`*[R, C, D, S](trans: Transform[R, C, S], pt: Point[D, S]): auto {.inline.} =
    let hom = to_homogeneous(pt)
    let res_hom = trans.m * hom
    result = from_homogeneous(res_hom)

proc abs_error*[R, C, D, S](trans: Transform[R, C, S], pt: Point[D, S]): auto {.inline.} =
    let hom = to_homogeneous(pt)
    var abs_transform = to_vector(abs(trans.m) * hom)
    abs_transform = abs_transform * fpe_term(3)
    result = from_homogeneous(abs_transform)

proc `()`*[R, C, D, S](trans: Transform[R, C, S], vec: Vector[D, S]): auto {.inline.} =
    let hom = to_homogeneous(vec)
    let res_hom = trans.m * hom
    result = from_homogeneous(res_hom)

proc abs_error*[R, C, D, S](trans: Transform[R, C, S], vec: Vector[D, S]): auto {.inline.} =
    let hom = to_homogeneous(vec)
    var abs_transform = abs(trans.m) * hom
    abs_transform = abs_transform * fpe_term(3)
    result = from_homogeneous(abs_transform)

proc `()`*[R, C, D, S](trans: Transform[R, C, S], norm: Normal[D, S]): auto {.inline.} =
    let hom = to_homogeneous(norm)
    let res_hom = transpose(trans.m_inv) * hom
    result = from_homogeneous(res_hom)

proc `()`*[R, C, D, S](trans: Transform[R, C, S], ray: Ray[D, S]): auto {.inline.} =
    result = deep_copy(ray)
    result.o = trans(ray.o)
    result.d = trans(ray.d)

proc abs_error*[R, C, D, S](trans: Transform[R, C, S], ray: Ray[D, S]): auto {.inline.} =
    [abs_error(trans, ray.o), abs_error(trans, ray.d)]

proc `()`*[R, C, D, S](trans: Transform[R, C, S], bnds: Bounds[D, S]): auto {.inline.} =
    let pt = trans(corner(bnds, 0))
    result = new_bounds(pt)
    for c in 1 ..< 8:
        let pt = trans(corner(bnds, c))
        result = union(result, pt)

proc `*`*[R, C, S](trans1, trans2: Transform[R, C, S]): Transform[R, C, S] =
    Transform[R, C, S](m: trans1.m * trans2.m, m_inv: trans2.m_inv * trans1.m_inv)
