import nuance/la/shared_vector
import nuance/la/bounds
import nuance/la/point
import nuance/la/transform

{.warning[Deprecated]: off.}

type
    Shape*[S: Scalar] = ref object of RootObj
        object_to_world*: Transform[4, 4, S]
        world_to_object*: Transform[4, 4, S]
        world_bounds_cached*: Bounds[3, S]

method `$`*[S](shape: Shape[S]): string {.base.} =
    "<Shape>"

proc transform_swaps_handedness*[S](shape: Shape[S]): bool = shape.object_to_world.swaps_handedness

proc reverse_orientation*[S](shape: Shape[S]): bool = false

method object_bounds*[S](shape: Shape[S]): Bounds[3, S] {.base gcsafe.} =
    new_bounds(Pt3(0.0, 0.0, 0.0), Pt3(0.0, 0.0, 0.0))

method surface_area*[S](shape: Shape[S]): S {.base.} = S(0)

method world_bounds*[S](shape: Shape[S]): Bounds[3, S] {.base gcsafe.} =
    if shape.world_bounds_cached.is_nil:
        shape.world_bounds_cached = shape.object_to_world(shape.object_bounds)
    return shape.world_bounds_cached

