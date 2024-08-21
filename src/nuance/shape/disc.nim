import math
import nuance/la/shared_vector
import nuance/la/bounds
import nuance/la/point
import nuance/la/transform
import shape

{.warning[Deprecated]: off.}

type
    Disc*[S: Scalar] = ref object of Shape[S]
        height: S
        radius, inner_radius: S
        phi_max: S

method `$`*[S](shape: Disc[S]): string {.base.} =
    "<Disc>"

method object_bounds*[S](disc: Disc[S]): Bounds[3, S] =
    return new_bounds(
      Pt3(-disc.radius, -disc.radius, -disc.height),
      Pt3(disc.radius, disc.radius, disc.height)
    )

proc surface_area*[S](disc: Disc[S]): S =
    disc.phi_max * S(0.5) * (disc.radius^2 - disc.inner_radius^2)

proc make*[S](T: type Disc, radius, inner_radius: S, object_to_world: Transform[4, 4, S]): Disc[S] =
    Disc[S](
        height: S(0),
        radius: radius,
        inner_radius: inner_radius,
        phi_max: deg_to_rad(360.0),
        object_to_world: object_to_world,
        world_to_object: inverse(object_to_world)
    )
