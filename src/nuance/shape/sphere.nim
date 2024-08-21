import math
import nuance/la/shared_vector
import nuance/la/bounds
import nuance/la/point
import nuance/la/transform
import shape

{.warning[Deprecated]: off.}

type
    Sphere*[S: Scalar] = ref object of Shape[S]
        radius*: S
        z_min*, z_max*: S
        theta_min*, theta_max*, phi_max*: S

method `$`*[S](shape: Sphere[S]): string =
    "<Sphere>"

method object_bounds*[S](sphere: Sphere[S]): Bounds[3, S] =
    return new_bounds(
      Pt3(-sphere.radius, -sphere.radius, sphere.z_min),
      Pt3(sphere.radius, sphere.radius, sphere.z_max)
    )

method surface_area*[S](sphere: Sphere[S]): S =
    sphere.phi_max * sphere.radius * (sphere.z_max - sphere.z_min)

proc make*[S](T: type Sphere, radius: S, object_to_world: Transform[4, 4, S]): Sphere[S] =
    Sphere[S](
      radius: radius, z_min: -radius, z_max: radius, phi_max: deg_to_rad(360.0),
      theta_min: arccos(-1.0), theta_max: arccos(1.0),
      object_to_world: object_to_world, world_to_object: inverse(object_to_world)
    )
