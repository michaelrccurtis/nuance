## Normal class and associated methods
import shared_vector
import vector


type
    Normal*[D: static[int], S: Scalar] = ref object
        arr*: array[D, S]


stringify(Normal)
vector_accessors_and_setters(Normal)
componentwise_op(Normal, `+`)
componentwise_op(Normal, `-`)
componentwise_op(Normal, `*`)
componentwise_op(Normal, `/`)
negation(Normal)
scalar_op(Normal, `*`, `*=`, doMult)
scalar_op(Normal, `/`, `/=`, doDivide)
dot_product(Normal, Normal)
dot_product(Vector, Normal)
dot_product(Normal, Vector)
length(Normal)
permute(Normal)


proc face_forward*[D, S](norm: Normal[D, S], vec: Vector[D, S]): Normal[D, S] =
    if norm *. vec < 0.0:
        return S(-1) * norm
    return norm

proc to_vector*[D, S](pt: Normal[D, S]): Vector[D, S] {.inline.} =
    result = Vector[D, S]()
    for idx in 0 ..< D:
        result[idx] = pt[idx]

proc to_normal*[D, S](pt: Vector[D, S]): Normal[D, S] {.inline.} =
    result = Normal[D, S]()
    for idx in 0 ..< D:
        result[idx] = pt[idx]

proc to_normal_cast*[D, S](pt: Vector[D, S]): Normal[D, S] {.inline.} =
    result = cast[Normal[D, S]](pt)

# Shortcuts for common Normal types
type
    Normal3*[S: Scalar] = Normal[3, S]
    Normal3f* = Normal3[float]

# Simple Constructors
proc ZerosNorm*[D, S](): Normal[D, S] =
    result = Normal[D, S]()
    for idx in 0 ..< D:
        result[idx] = S(0)

proc Norm3*[S](x, y, z: S): Normal[3, S] {.inline.} =
    result = Normal[3, S](arr: [x, y, z])
