import shared_vector
import vector
import point

{.experimental: "callOperator".}

type
    Ray*[D: static[int], S: Scalar] = ref object of RootObj
        o*: Point[D, S]
        d*: Vector[D, S]
        t_max*: S
        time*: S

proc `$`*[D, S](ray: Ray[D, S]): string =
    "<Ray o:" & $ray.o & " d:" & $ray.d & ">"

proc init*[D, S](
  T: typedesc[Ray[D, S]],
  o: Point[D, S], d: Vector[D, S], t_max = Inf, time = S(0)
): auto =
    T(
      o: o, d: d, t_max: t_max, time: time
    )

proc `()`*[D, S](ray: Ray[D, S], t: S): Point[D, S] {.inline.} =
    ray.o + ray.d * t

type
    RayDifferential*[D: static[int], S: Scalar] = ref object of Ray[D, S]
        has_differentials*: bool
        rx_origin*: Point[D, S]
        rx_direction*: Vector[D, S]
        ry_origin*: Point[D, S]
        ry_direction*: Vector[D, S]


proc scale_differentials*[D, S](ray: RayDifferential[D, S], scale: S) =
    ray.rx_origin = ray.o + (ray.rx_origin - ray.o) * scale
    ray.ry_origin = ray.o + (ray.ry_origin - ray.o) * scale
    ray.rx_direction = ray.d + (ray.rx_direction - ray.d) * scale
    ray.ry_direction = ray.d + (ray.ry_direction - ray.d) * scale


# Simple Constructors

proc Ray3*[S](pt: Point[3, S], vec: Vector[3, S]): Ray[3, S] {.inline.} =
    result = Ray[3, S](o: pt, d: vec, t_max: Inf)

proc RayD3*[S](ray: Ray[3, S]): RayDifferential[3, S] {.inline.} =
    result = RayDifferential[3, S](
      o: ray.o, d: ray.d, t_max: ray.t_max, time: ray.time, has_differentials: false
    )

proc newRay*[D, S](o: Point[D, S], d: Vector[D, S]): Ray[D, S] =
    Ray[D, S](o: o, d: d, time: 0, t_max: Inf)
