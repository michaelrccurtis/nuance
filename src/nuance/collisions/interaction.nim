import nuance/la/shared_vector
import nuance/la/vector
import nuance/la/point
import nuance/la/normal
import nuance/la/transform
import nuance/la/ray
import nuance/shape/shape
import nuance/math/fp

{.experimental: "callOperator".}

type
    Interaction*[D: static[int], S: Scalar] = ref object of RootObj
        p*: Point[D, S]
        p_error*: Vector[D, S]
        time*: S
        wo*: Vector[D, S]
        n*: Normal[D, S]

    SurfaceInteraction*[D: static[int], P: static[int], S: Scalar] = ref object of Interaction[D, S]
        uv*: Point[P, S]
        dpdu*: Vector[D, S]
        dpdv*: Vector[D, S]
        dndu*: Normal[D, S]
        dndv*: Normal[D, S]

        shape*: Shape[S]
        # Todo: shading

proc new_surface_interaction*[D, P, S](
  n: Normal, dpdu, dpdv: Vector[D, S], dndu, dndv: Normal[D, S]
): SurfaceInteraction[D, P, S] =
    result = SurfaceInteraction[D, P, S](
      n: n, dpdu: dpdu, dpdv: dpdv, dndu: dndu, dndv: dndv
    )
    # Todo: establish where we should account for transform handeness change in normals:

proc `()`*[R, C, D, P, S](trans: Transform[R, C, S], act: SurfaceInteraction[D, P, S]): auto {.inline.} =
    result = deep_copy(act)

    result.p = trans(act.p)
    result.p_error = trans(act.p_error)

    result.wo = norm(trans(act.wo))
    result.n = norm(trans(act.n))

    result.uv = act.uv
    result.dpdu = trans(act.dpdu)
    result.dpdv = trans(act.dpdv)
    result.dndu = trans(act.dndu)
    result.dndv = trans(act.dndv)

proc offset_ray_origin*[S](p: Point[3, S], p_error: Vector[3, S], n: Normal[3, S], w: Vector[3, S]): Point[3, S] =
    let d = dot(abs(n), p_error)
    var offset = d * to_vector(n)

    if dot(w, n) < 0:
        offset = -offset

    result = p + offset

    for i in 0 ..< 3:
        if offset[i] > 0:
            result[i] = next_float_up(result[i])
        elif offset[i] < 0:
            result[i] = next_float_down(result[i])

proc new_ray*[D, P, S](act: SurfaceInteraction[D, P, S], d: Vector[D, S]): Ray[D, S] =
    let o = offset_ray_origin(act.p, act.p_error, act.n, d)
    result = new_ray(o, d)
