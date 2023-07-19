import math
import nuancepkg/la/shared_vector
import nuancepkg/la/bounds
import nuancepkg/la/point
import nuancepkg/la/transform
import shape

{.warning[Deprecated]: off.}

type
    Cylinder*[S: Scalar] = ref object of Shape[S]
        radius*: S
        z_min*, z_max*: S
        phi_max*: S

method object_bounds*[S](cylinder: Cylinder[S]): Bounds[3, S] =
    return new_bounds(
      Pt3(-cylinder.radius, -cylinder.radius, cylinder.z_min),
      Pt3(cylinder.radius, cylinder.radius, cylinder.z_max)
    )

proc surface_area*[S](cylinder: Cylinder[S]): S =
    (cylinder.z_max - cylinder.z_min) * cylinder.radius * cylinder.phi_max

proc make*[S](T: type Cylinder, radius, z_min, z_max: S, object_to_world: Transform[4, 4, S]): Cylinder[S] =
    Cylinder[S](
      radius: radius, z_min: z_min, z_max: z_max, phi_max: deg_to_rad(360.0),
      object_to_world: object_to_world, world_to_object: inverse(object_to_world)
    )
