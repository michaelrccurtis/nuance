import math
import nuancepkg/math/efloat
import nuancepkg/la/vector
import nuancepkg/la/point
import nuancepkg/la/normal
import nuancepkg/la/ray
import nuancepkg/shape/disc
import interaction
import shape

{.warning[Deprecated]: off.}

method get_collisions*[S](dsc: Disc[S], ray: Ray[3, S]): ShapeCollisionResult[S] =
    let
        t_ray = dsc.world_to_object(ray)
        ray_err = dsc.world_to_object.absError(ray)

    if t_ray.d.z == 0: return ShapeCollisionResult[S](collides: false)
    let t_hit = (dsc.height - t_ray.o.z) / t_ray.d.z

    if t_hit <= 0 or t_hit >= t_ray.t_max: return ShapeCollisionResult[S](collides: false)

    var p_hit = t_ray(t_hit)
    let dist_squared = p_hit.x^2 + p_hit.y^2
    if dist_squared > dsc.radius^2 or dist_squared < dsc.inner_radius^2:
        return ShapeCollisionResult[S](collides: false)
    var phi = arctan2(p_hit.y, p_hit.x)
    if phi < 0:
        phi += 2 * Pi
    if phi > dsc.phi_max:
        return ShapeCollisionResult[S](collides: false)

    let
        u = phi / dsc.phi_max
        r_hit = sqrt(dist_squared)
        v = (dsc.radius - r_hit) / (dsc.radius - dsc.inner_radius)
        dpdu = Vector[3, S](arr: [-dsc.phi_max * p_hit.y, dsc.phi_max * p_hit.x, S(0)])
        dpdv = Vector[3, S](arr: [p_hit.x, p_hit.y, S(0)]) * (dsc.inner_radius - dsc.radius) / r_hit
        dndu = ZerosNorm[3, S]()
        dndv = ZerosNorm[3, S]()
        N = dpdu *^ dpdv

    let
        p_error = ZerosVec[3, S]()
        interaction = SurfaceInteraction[3, 2, S](
          p: p_hit,
          p_error: p_error,
          uv: Point[2, S](arr: [u, v]),
          wo: (-t_ray.d),
          n: to_normal(N),
          dpdu: dpdu,
          dpdv: dpdv,
          dndu: dndu,
          dndv: dndv,
          time: t_ray.time,
          shape: dsc
        )

    return ShapeCollisionResult[S](
      collides: true, t_hit: t_hit, interaction: interaction
    )


method collides*[S](dsc: Disc[S], ray: Ray[3, S]): bool =
    # Transform the ray to shape coords and get the error
    let
        t_ray = dsc.world_to_object(ray)
        ray_err = dsc.world_to_object.absError(ray)

    if t_ray.d.z == 0: return false
    let t_hit = (dsc.height - t_ray.o.z) / t_ray.d.z

    if t_hit <= 0 or t_hit >= t_ray.t_max: return false

    let
        p_hit = t_ray(t_hit)
        dist_squared = p_hit.x^2 + p_hit.y^2
    if dist_squared > dsc.radius^2 or dist_squared < dsc.inner_radius^2:
        return false
    var phi = arctan2(p_hit.y, p_hit.x)
    if phi < 0:
        phi += 2 * Pi
    return phi <= dsc.phi_max
