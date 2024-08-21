import math
import nuance/math/efloat
import nuance/math/fp
import nuance/math/quadratic
import nuance/la/vector
import nuance/la/point
import nuance/la/normal
import nuance/la/ray
import nuance/shape/cylinder
import interaction
import shape

{.warning[Deprecated]: off.}

proc get_phi[S](y, x, radius: S): S =
    if x == 0 and y == 0:
        result = arctan2(y, 1.0e-5 * radius)
    else:
        result = arctan2(y, x)

    if result < 0:
        result += 2 * PI

proc outside_bounds[S](cyl: Cylinder[S], phi, z: S): bool =
    z < cyl.z_min or z > cyl.z_max or phi > cyl.phi_max

proc validate_collision[S](cyl: Cylinder[S], pt: Point[3, S]): bool =
    return not cyl.outside_bounds(get_phi(pt.y, pt.x, cyl.radius), pt.z)

proc get_p_hit[D, S](cyl: Cylinder[S], ray: Ray[3, S], t: S): Point[3, S] =
    result = ray(t)
    # This should be ~= 1.0 as we are in shape coordinates
    let hit_rad = sqrt(result.x^2 + result.y^2)
    result.x *= cyl.radius / hit_rad
    result.y *= cyl.radius / hit_rad

method get_collisions*[S: SomeNumber](cyl: Cylinder[S], ray: Ray[3, S]): ShapeCollisionResult[S] =
    # Transform the ray to shape coords and get the error
    let
        t_ray = cyl.world_to_object(ray)
        ray_err = cyl.world_to_object.abs_error(ray)

    # construct intersection equation
    let
        o = e_vector[3, S, Efloat[S]](to_vector(t_ray.o), ray_err[0])
        d = e_vector[3, S, Efloat[S]](t_ray.d, ray_err[1])

    o.z = efloat(S(0))
    d.z = efloat(S(0))

    let
        a = length_squared(d)
        b = S(2) * dot(d, o)
        c = length_squared(o) - (cyl.radius^2)

    if not quadratic_solvable(a, b, c): return ShapeCollisionResult[S](collides: false)

    let
        quad = quadratic(a, b, c)
        t0 = quad[0]
        t1 = quad[1]

    # Are collisions outside the bounds of the ray?
    if t0.v_high > t_ray.t_max or t1.v_low <= 0: return ShapeCollisionResult[S](collides: false)

    var p_hit: Point[3, S] = get_p_hit[3, S](cyl, t_ray, to_float(t0))

    var t_hit = t0
    if not (validate_collision(cyl, p_hit) and t0.v_low > 0):
        p_hit = get_p_hit[3, S](cyl, t_ray, to_float(t1))
        if validate_collision(cyl, p_hit) and t1.v_high <= t_ray.t_max:
            t_hit = t1
        else:
            return ShapeCollisionResult[S](collides: false)

    let
        u = get_phi(p_hit.y, p_hit.x, cyl.radius) / cyl.phi_max
        v = (p_hit.z - cyl.z_min) / (cyl.z_max - cyl.z_min)

    # dpdu, dpdv
    let
        dpdu = Vector[3, S](arr: [-cyl.phi_max * p_hit.y, cyl.phi_max * p_hit.x, S(0)])
        dpdv = Vector[3, S](arr: [S(0), S(0), cyl.z_max - cyl.z_min])

        d2Pduu = -cyl.phi_max^2 * Vector[3, S](arr: [p_hit.x, p_hit.y, S(0)])
        d2Pduv = ZerosVec[3, S]()
        d2Pdvv = ZerosVec[3, S]()

    # Compute coefficients for fundamental forms
    let
        E = dot(dpdu, dpdu)
        F = dot(dpdu, dpdv)
        G = dot(dpdv, dpdv)
        N = norm(dpdu *^ dpdv)
        e = dot(N, d2Pduu)
        f = dot(N, d2Pduv)
        g = dot(N, d2Pdvv)

    # Compute $\dndu$ and $\dndv$ from fundamental form coefficients
    let
        invEGF2 = S(1) / (E * G - F * F)
        dndu = to_normal(
          (f * F - e * G) * invEGF2 * dpdu +
          (e * F - f * E) * invEGF2 * dpdv
        )
        dndv = to_normal(
          (g * F - f * G) * invEGF2 * dpdu +
          (f * F - g * E) * invEGF2 * dpdv
        )
        p_error = fpe_term(5) * abs(Vector[3, S](arr: [p_hit.x, p_hit.y, S(0)]))

        interaction = SurfaceInteraction[3, 2, S](
            p: p_hit,
            p_error: p_error,
            uv: Point[2, S](arr: [u, v]),
            wo: (-t_ray.d),
            n: to_normal(N),
            dpdu: dpdu, dpdv: dpdv, dndu: dndu, dndv: dndv,
            time: t_ray.time, shape: cyl
        )

    return ShapeCollisionResult[S](
      collides: true, t_hit: to_float(t_hit), interaction: interaction
    )

method collides*[S](cyl: Cylinder[S], ray: Ray[3, S]): bool =
    let
        t_ray = cyl.world_to_object(ray)
        ray_err = cyl.world_to_object.abs_error(ray)

    let
        o = e_vector[3, S, Efloat[S]](to_vector(t_ray.o), ray_err[0])
        d = e_vector[3, S, Efloat[S]](t_ray.d, ray_err[1])


    o.z = efloat(S(0))
    d.z = efloat(S(0))

    let
        a = length_squared(d)
        b = 2.0 * dot(d, o)
        c = length_squared(o) - (cyl.radius^2)

    if not quadratic_solvable(a, b, c): return false

    let
        quad = quadratic(a, b, c)
        t0 = quad[0]
        t1 = quad[1]

    # Are collisions outside the bounds of the ray?
    if t0.v_high > t_ray.t_max or t1.v_low <= 0: return false

    var t_hit = t0

    if t_hit.v_low <= 0:
        t_hit = t1

        if t_hit.v_high > t_ray.t_max:
            return false

    var p_hit: Point[3, S] = t_ray(to_float(t_hit))
    if validate_collision(cyl, p_hit) and t0.v_low > 0:
        return true

    p_hit = t_ray(to_float(t1))
    return validate_collision(cyl, p_hit) and t1.v_high <= t_ray.t_max
