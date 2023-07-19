## Point class and associated methods
import math
import shared_vector
import vector


type
    Point*[D: static[int], S: Scalar] = ref object
        arr*: array[D, S]


stringify(Point)
vector_accessors_and_setters(Point)
componentwise_op(Point, `+`)
componentwise_op(Point, `*`)
componentwise_op(Point, `/`)
negation(Point)
scalar_op(Point, `*`, `*=`, doMult)
scalar_op(Point, `/`, `/=`, doDivide)
dot_product(Point, Point)
length(Point)
cross_product(Point)
permute(Point)
max_and_min(Point)


proc `+`*[D, S](pt: Point[D, S], vec: Vector[D, S]): Point[D, S] {.inline.} =
    result = Point[D, S]()
    for idx in 0 ..< D:
        result.arr[idx] = pt.arr[idx] + vec.arr[idx]

proc `-`*[D, S](pt: Point[D, S], vec: Vector[D, S]): Point[D, S] {.inline.} =
    result = Point[D, S]()
    for idx in 0 ..< D:
        result.arr[idx] = pt.arr[idx] - vec.arr[idx]

proc `-`*[D, S](pt1, pt2: Point[D, S]): Vector[D, S] {.inline.} =
    result = Vector[D, S]()
    for idx in 0 ..< D:
        result.arr[idx] = pt1.arr[idx] - pt2.arr[idx]

proc distance*[D, S](pt1, pt2: Point[D, S]): S {.inline.} =
    length(pt2 - pt1)

proc distance_squared*[D, S](pt1, pt2: Point[D, S]): S {.inline.} =
    length_squared(pt2 - pt1)

proc linearInterp*[D, S](t: S, pt1, pt2: Point[D, S]): Point[D, S] {.inline.} =
    (1 - t) * pt1 + t * pt2

proc floor*[D, S](pt: Point[D, S]): Point[D, S] {.inline.} =
    result = Point[D, S]()
    for idx in 0 ..< D:
        result[idx] = floor(pt[idx])

proc ceil*[D, S](pt: Point[D, S]): Point[D, S] {.inline.} =
    result = Point[D, S]()
    for idx in 0 ..< D:
        result[idx] = ceil(pt[idx])

proc to_vector*[D, S](pt: Point[D, S]): Vector[D, S] {.inline.} =
    result = cast[Vector[D, S]](pt)


# Shortcuts for common vectors

type
    Point2*[S: Scalar] = Point[2, S]
    Point3*[S: Scalar] = Point[3, S]
    Point2f* = Point2[float]
    Point3f* = Point3[float]


# Simple Constructors

proc Pt2*[S](x, y: S): Point[2, S] {.inline.} =
    result = Point[2, S](arr: [x, y])
proc Pt3*[S](x, y, z: S): Point[3, S] {.inline.} =
    result = Point[3, S](arr: [x, y, z])

proc IdPoint*[D, S](cpt: S): Point[D, S] {.inline.} =
    result = Point[D, S]()
    for idx in 0 ..< D:
        result[idx] = cpt

proc Origin*[D, S](): Point[D, S] {.inline.} =
    IdPoint[D, S](S(0))

let Origin2f* = Origin[3, float]()
let Origin3f* = Origin[3, float]()
