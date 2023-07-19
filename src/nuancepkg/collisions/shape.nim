import nuancepkg/la/shared_vector
import nuancepkg/la/ray
import nuancepkg/shape/shape
import collisions
import interaction

{.warning[Deprecated]: off.}

type
    ShapeCollisionResult*[S: Scalar] = ref object of CollisionResult[3, S]
        interaction*: SurfaceInteraction[3, 2, S]

method get_collisions*[S](shape: Shape[S], ray: Ray[3, S]): ShapeCollisionResult[S] {.base.} =
    ShapeCollisionResult[S](collides: false)

method collides*[S](shape: Shape[S], ray: Ray[3, S]): bool {.base.} =
    get_collisions(shape, ray).collides
