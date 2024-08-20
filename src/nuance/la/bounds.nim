import nuance/math/utils
import shared_vector
import point
import vector

type
    Bounds*[D: static[int], S: Scalar] = ref object
        p_min*: Point[D, S]
        p_max*: Point[D, S]
    BoundsSphere*[D: static[int], S: Scalar] = ref object
        center*: Point[D, S]
        radius*: S

proc `$`*[D, S](bnds: Bounds[D, S]): string =
    result = "{ " & $bnds.p_min & ", " & $bnds.p_max & " }"

# Constructors
proc new_bounds*[D, S](pt: Point[D, S]): Bounds[D, S] {.inline.} =
    Bounds[D, S](p_min: pt, p_max: pt)

proc new_bounds*[D, S](pt1, pt2: Point[D, S]): Bounds[D, S] {.inline.} =
    Bounds[D, S](p_min: min(pt1, pt2), p_max: max(pt1, pt2))

proc max_bounds*[D, S](): Bounds[D, S] {.inline.} =
    Bounds[D, S](
      p_min: IdPoint[D, S](low(S)), p_max: IdPoint[D, S](high(S))
    )

proc `==`*[D, S](bnds1, bnds2: Bounds[D, S]): bool {.inline.} =
    result = (bnds1.p_min == bnds2.p_min) and (bnds2.p_max == bnds2.p_max)

proc corner*[S](bnds: Bounds[3, S], corner: int): Point[3, S] {.inline.} =
    result = deepCopy(bnds.p_min)
    if (corner and 1) > 0:
        result.x = bnds.p_max.x
    if (corner and 2) > 0:
        result.y = bnds.p_max.y
    if (corner and 4) > 0:
        result.z = bnds.p_max.z

proc union*[D, S](bnds: Bounds[D, S], pt: Point[D, S]): Bounds[D, S] {.inline.} =
    Bounds[D, S](p_min: min(bnds.p_min, pt), p_max: max(bnds.p_max, pt))

proc union*[D, S](bnds1, bnds2: Bounds[D, S]): Bounds[D, S] {.inline.} =
    Bounds[D, S](p_min: min(bnds1.p_min, bnds2.p_min), p_max: max(bnds1.p_max, bnds2.p_max))

proc intersect*[D, S](bnds1, bnds2: Bounds[D, S]): Bounds[D, S] {.inline.} =
    Bounds[D, S](p_min: max(bnds1.p_min, bnds2.p_min), p_max: min(bnds1.p_max, bnds2.p_max))

proc overlaps*[D, S](bnds1, bnds2: Bounds[D, S]): bool {.inline.} =
    result = true
    for idx in 0 ..< D:
        result = result and bnds1.p_max[idx] >= bnds2.p_min[idx]
        result = result and bnds1.p_min[idx] <= bnds2.p_max[idx]

proc inside*[D, S](bnds: Bounds[D, S], pt: Point[D, S]): bool {.inline.} =
    result = true
    for idx in 0 ..< D:
        result = result and pt[idx] >= bnds.p_min[idx]
        result = result and pt[idx] <= bnds.p_max[idx]

proc inside_exclusive*[D, S](bnds: Bounds[D, S], pt: Point[D, S]): bool {.inline.} =
    result = true
    for idx in 0 ..< D:
        result = result and pt[idx] >= bnds.p_min[idx]
        result = result and pt[idx] < bnds.p_max[idx]

proc expand*[D, S](bnds: Bounds[D, S], delta: S): Bounds[D, S] {.inline.} =
    result = Bounds[D, S]()
    result.p_min = bnds.p_min + IdPoint[D, S](-delta)
    result.p_max = bnds.p_max + IdPoint[D, S](delta)

proc diagonal*[D, S](bnds: Bounds[D, S]): Vector[D, S] {.inline.} =
    bnds.p_max - bnds.p_min


proc surface_area*[S](bnds: Bounds[2, S]): S {.inline.} =
    let d = diagonal(bnds)
    result = d.x * d.y

proc surface_area*[S](bnds: Bounds[3, S]): S {.inline.} =
    let d = diagonal(bnds)
    result = 2 * (d.x * d.y + d.x * d.z + d.y * d.z)

proc volume*[S](bnds: Bounds[3, S]): S {.inline.} =
    let d = diagonal(bnds)
    result = d.x * d.y * d.z

proc maximum_extent*[S](bnds: Bounds[3, S]): int {.inline.} =
    max_dim(diagonal(bnds))

proc linear_interp*[D, S](bnds: Bounds[D, S], pt: Point[D, S]): Point[D, S] {.inline.} =
    result = Point[D, S]()
    for idx in 0 ..< D:
        result[idx] = linear_interp(pt[idx], bnds.p_min[idx], bnds.p_max[idx])

proc offset*[D, S](bnds: Bounds[D, S], pt: Point[D, S]): Vector[D, S] {.inline.} =
    result = pt - bnds.p_min
    for idx in 0 ..< D:
        if (bnds.p_max[idx] > bnds.p_min[idx]):
            result[idx] /= bnds.p_max[idx] - bnds.p_min[idx]

proc bounding_sphere*[D, S](bnds: Bounds[D, S]): BoundsSphere[D, S] {.inline.} =
    let center = (bnds.p_min + bnds.p_max) / 2
    let radius = if inside(bnds, center): distance(center, bnds.p_max) else: 0
    result = BoundsSphere(center: center, radius: radius)
