import nuancepkg/la/bounds
import nuancepkg/la/ray
import nuancepkg/la/point
import nuancepkg/la/vector
import collisions

proc get_collisions*[D, S](bnds: Bounds[D, S], ray: Ray[D, S]): CollisionResult[D, S] =
    var
        t0 = S(0)
        t1 = ray.t_max

    for idx in 0 ..< D:
        let
            inv_ray_dir = S(1) / ray.d[idx]
        var
            t_near = (bnds.p_min[idx] - ray.o[idx]) * inv_ray_dir
            t_far = (bnds.p_max[idx] - ray.o[idx]) * inv_ray_dir

        if t_near > t_far:
            swap(t_near, t_far)

        t0 = if t_near > t0: t_near else: t0
        t1 = if t_far < t1: t_far else: t1

    if t0 > t1:
        return CollisionResult[D, S](collides: false)

    return CollisionResult[D, S](
      collides: true, t_hit: t1
    )

proc collides*[D, S](
  bnds: Bounds[D, S], ray: Ray[D, S]
): bool =

    var
        t0 = S(0)
        t1 = ray.t_max

    for idx in 0 ..< D:
        let
            inv_ray_dir = S(1) / ray.d[idx]

        var
            t_near = (bnds.p_min[idx] - ray.o[idx]) * inv_ray_dir
            t_far = (bnds.p_max[idx] - ray.o[idx]) * inv_ray_dir

        if t_near > t_far:
            swap(t_near, t_far)

        t0 = if t_near > t0: t_near else: t0
        t1 = if t_far < t1: t_far else: t1

        if t0 > t1:
            return false
    return true
