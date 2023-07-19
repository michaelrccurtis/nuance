import std/strformat
import nuancepkg/la/shared_vector
import nuancepkg/la/bounds
import nuancepkg/la/ray
import nuancepkg/shape/shape
import nuancepkg/collisions/all
import nuancepkg/materials/material

{.warning[Deprecated]: off.}

type Primitive*[S: Scalar] = ref object of RootObj

method `$`*[S](prim: Primitive[S]): string {.base.} =
    "<BasePrimative>"

method world_bounds*[S](primitive: Primitive[S]): Bounds[3, S] {.base.} =
    return Bounds[3, S]()

method get_collisions*[S](primitive: Primitive[S], ray: Ray[3, S]): CollisionResult[3, S] {.base.} =
    return CollisionResult[3, S]()

method collides*[S](primitive: Primitive[S], ray: Ray[3, S]): bool {.base.} =
    return false

type
    GeometricPrimitive*[S] = ref object of Primitive[S]
        shape*: Shape[S]
        material*: Material[S]

    PrimitiveScatteringResult*[S] = ref object
        collides*: bool
        t_hit*: S
        interaction*: SurfaceInteraction[3, 2, S]
        primitive*: GeometricPrimitive[S]

method `$`*[S](prim: GeometricPrimitive[S]): string {.base.} =
    fmt"<GeometricPrimative shape={prim.shape} material={prim.material}>"

proc make*[S](T: type GeometricPrimitive, shape: Shape[S]): GeometricPrimitive[S] =
    GeometricPrimitive[S](shape: shape, material: Material[S]())

proc make*[S](T: type GeometricPrimitive, shape: Shape[S], mat: Material[S]): GeometricPrimitive[S] =
    GeometricPrimitive[S](shape: shape, material: mat)

method world_bounds*[S](primitive: GeometricPrimitive[S]): Bounds[3, S] =
    primitive.shape.world_bounds

method get_collisions*[S](primitive: GeometricPrimitive[S], ray: Ray[3, S]): ShapeCollisionResult[S] {.base.} =
    primitive.shape.get_collisions(ray)

method collides*[S](primitive: GeometricPrimitive[S], ray: Ray[3, S]): bool =
    primitive.shape.collides(ray)

type PrimitiveGroup*[S] = ref object of Primitive[S]
    primitives*: seq[GeometricPrimitive[S]]

proc new_group*[S](primitives: seq[GeometricPrimitive[S]]): PrimitiveGroup[S] =
    PrimitiveGroup[S](
      primitives: primitives
    )

method get_collisions*[S](group: PrimitiveGroup[S], ray: Ray[3, S]): PrimitiveScatteringResult[S] {.base.} =
    var
        collides = false
        collision_result: PrimitiveScatteringResult[S]

    for primitive in group.primitives:
        if primitive.shape.world_bounds.collides(ray):
            let collision = primitive.get_collisions(ray)
            if collision.collides:
                if not collides or collision.t_hit < collision_result.t_hit:
                    collision_result = PrimitiveScatteringResult[S](
                        collides: true,
                        t_hit: collision.t_hit,
                        interaction: collision.interaction,
                        primitive: primitive
                    )
                    collides = true

    if collides:
        return collision_result
    return PrimitiveScatteringResult[S](collides: false)

method collides*[S](group: PrimitiveGroup[S], ray: Ray[3, S]): tuple[collides: bool, index: int] {.base.} =
    for idx, primitive in group.primitives:
        if primitive.collides(ray):
            return (true, idx)
    return (false, -1)
