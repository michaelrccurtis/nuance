## Vector class and associated methods
import nuancepkg/math/efloat
import shared_vector
import std/[random, math]

type
    Vector*[D: static[int], S: Scalar] = ref object
        arr*: array[D, S]


stringify(Vector)
vector_accessors_and_setters(Vector)
componentwise_op(Vector, `+`)
componentwise_opeq(Vector, `+`, `+=`)
componentwise_op(Vector, `-`)
componentwise_op(Vector, `*`)
componentwise_op(Vector, `/`)
negation(Vector)
scalar_op(Vector, `*`, `*=`, doMult)
scalar_op(Vector, `/`, `/=`, doDivide)
dot_product(Vector, Vector)
length(Vector)
cross_product(Vector)
permute(Vector)
max_and_min(Vector)


# Misc
proc min_cpt*[D, S](vec: Vector[D, S]): S {.inline.} =
    min(vec.arr)

proc max_cpt*[D, S](vec: Vector[D, S]): S {.inline.} =
    max(vec.arr)

proc max_dim*[D, S](vec: Vector[D, S]): int {.inline.} =
    result = 0
    for idx in 1 ..< D:
        if vec[idx] > vec[result]:
            result = idx

# Shortcuts for common Vector types
type
    Vector2*[S: Scalar] = Vector[2, S]
    Vector3*[S: Scalar] = Vector[3, S]
    Vector4*[S: Scalar] = Vector[4, S]
    Vector2f* = Vector2[float]
    Vector3f* = Vector3[float]
    Vector4f* = Vector4[float]

proc ZerosVec*[D, S](): Vector[D, S] =
    result = Vector[D, S]()
    for idx in 0 ..< D:
        result[idx] = S(0)

proc OneHotVec*[D, S](idx: int): Vector[D, S] =
    result = ZerosVec[D, S]()
    result[idx] = S(1)

proc eVector*[D, S, ES](v, vErr: Vector[D, S]): Vector[D, ES] =
    result = Vector[D, ES]()
    for idx in 0 ..< D:
        result[idx] = from_pair(v[idx], vErr[idx])

proc Vec2*[S](x, y: S): Vector[2, S] {.inline.} =
    result = Vector[2, S](arr: [x, y])

proc Vec3*[S](x, y, z: S): Vector[3, S] {.inline.} =
    result = Vector[3, S](arr: [x, y, z])


proc Vec3InUnitSphere*(): Vector[3, float] =
    while true:
        let p = Vec3(rand(2.0) - 1, rand(2.0) - 1, rand(2.0) - 1)
        if length(p) < 1.0:
            return p

proc Vec3OnUnitSphere*(): Vector[3, float] =
    result = norm(Vec3InUnitSphere())

proc reflect*[D, S](v, n: Vector[D, S]): Vector[D, S] =
    result = v - 2*dot(v, n)*n

proc refract*[D, S](uv, n: Vector[D, S], etai_over_etat: float): Vector[D, S] =
    let
        cos_theta = min(dot(-uv, n), 1.0)
        r_out_perp = S(etai_over_etat) * (uv + cos_theta*n)
        r_out_parallel = -sqrt(abs(1.0 - r_out_perp.length_squared())) * n

    result = r_out_perp + r_out_parallel


