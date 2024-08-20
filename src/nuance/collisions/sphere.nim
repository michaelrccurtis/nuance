import math
import nuance/math/efloat
import nuance/math/fp
import nuance/math/quadratic
import nuance/la/shared_vector
import nuance/la/vector
import nuance/la/point
import nuance/la/normal
import nuance/la/ray
import nuance/shape/sphere
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

proc outside_bounds[S](sp: Sphere[S], phi, z: S): bool =
    (sp.z_min > -sp.radius and z < sp.z_min) or (sp.zMax < sp.radius and z > sp.zMax) or phi > sp.phi_max

proc validate_collision[S](sp: Sphere[S], pt: Point[3, S]): bool =
    return not sp.outside_bounds(get_phi(pt.y, pt.x, sp.radius), pt.z)

method get_collisions*[S](sp: Sphere[S], ray: Ray[3, S]): ShapeCollisionResult[S] =
    let
        t_ray = sp.world_to_object(ray)
        ray_err = sp.world_to_object.abs_error(ray)

    let
        o = e_vector[3, S, Efloat[S]](to_vector(t_ray.o), ray_err[0])
        d = e_vector[3, S, Efloat[S]](t_ray.d, ray_err[1])
        a = length_squared(d)
        b = 2 * dot(d, o)
        c = length_squared(o) - (sp.radius^2)

    if not quadratic_solvable(a, b, c): return ShapeCollisionResult[S](collides: false)

    let
        quad = quadratic(a, b, c)
        t0 = quad[0]
        t1 = quad[1]

    if t0.v_high > t_ray.t_max or t1.v_low <= 0: return ShapeCollisionResult[S](collides: false)

    var p_hit: Point[3, S] = t_ray(to_float(t0))
    p_hit = p_hit * (sp.radius / length(p_hit))

    var t_hit = t0
    if not (validate_collision(sp, p_hit) and t0.v_low > 0):
        p_hit = t_ray(to_float(t1))
        p_hit = p_hit * (sp.radius / length(p_hit))
        if validate_collision(sp, p_hit) and t1.v_high <= t_ray.t_max:
            t_hit = t1
        else:
            return ShapeCollisionResult[S](collides: false)

    let
        u = get_phi(p_hit.y, p_hit.x, sp.radius) / sp.phi_max
        theta = arccos(clamp(p_hit.z / sp.radius, S(-1), S(1)))
        v = (theta - sp.theta_min) / (sp.theta_max - sp.theta_min)

    let
        inv_z_radius = S(1) / sqrt(p_hit.x^2 + p_hit.y^2)
        cos_phi = p_hit.x * inv_z_radius
        sin_phi = p_hit.y * inv_z_radius
        dpdu = Vec3(-sp.phi_max * p_hit.y, sp.phi_max * p_hit.x, S(0))
        dpdv = (sp.theta_max - sp.theta_min) * Vec3(
          p_hit.z * cos_phi, p_hit.z * sin_phi, -sp.radius * sin(theta)
        )
        d2Pduu = -sp.phi_max * sp.phi_max * Vec3(p_hit.x, p_hit.y, S(0))
        d2Pduv = (sp.theta_max - sp.theta_min) * p_hit.z * sp.phi_max * Vec3(
          -sin_phi, cos_phi, S(0)
        )
        d2Pdvv = -(sp.theta_max - sp.theta_min) * (sp.theta_max - sp.theta_min) * Vec3(
          p_hit.x, p_hit.y, p_hit.z
        )

    let
        E = dot(dpdu, dpdu)
        F = dot(dpdu, dpdv)
        G = dot(dpdv, dpdv)
        N = norm(dpdu *^ dpdv)
        e = dot(N, d2Pduu)
        f = dot(N, d2Pduv)
        g = dot(N, d2Pdvv)

    var normal = to_normal(N)

    if sp.transform_swaps_handedness:
        normal = -S(1) * normal

    let tn = sp.object_to_world(normal)
    normal = norm(tn)

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
        p_error = fpe_term(5) * abs(to_vector(p_hit))

        interaction = SurfaceInteraction[3, 2, S](
          p: p_hit,
          p_error: p_error,
          uv: Point[2, S](arr: [u, v]),
          wo: (-t_ray.d),
          n: normal,
          dpdu: dpdu,
          dpdv: dpdv,
          dndu: dndu,
          dndv: dndv,
          time: t_ray.time,
          #shape: sphre
        )
    return ShapeCollisionResult[S](
        collides: true, t_hit: to_float(t_hit), interaction: interaction
    )
    

method collides*[S](sp: Sphere[S], ray: Ray[3, S]): bool =
    let
        t_ray = sp.world_to_object(ray)
        ray_err = sp.world_to_object.abs_error(ray)

    let
        o = e_vector[3, S, Efloat[S]](to_vector(t_ray.o), ray_err[0])
        d = e_vector[3, S, Efloat[S]](t_ray.d, ray_err[1])
        a = length_squared(d)
        b = 2 * dot(d, o)
        c = length_squared(o) - (sp.radius^2)

    if not quadratic_solvable(a, b, c): return false

    let
        quad = quadratic(a, b, c)
        t0 = quad[0]
        t1 = quad[1]

    if t0.v_high > ray.t_max or t1.v_low <= 0: return false

    var p_hit: Point[3, S] = t_ray(to_float(t0))
    if validate_collision(sp, p_hit) and t0.v_low > 0:
        return true

    p_hit = ray(to_float(t1))
    return validate_collision(sp, p_hit) and t1.v_high <= ray.t_max
