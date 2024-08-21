import std/strformat
import nuance/la/shared_vector
import nuance/la/point
import nuance/la/bounds
import nuance/la/ray
import nuance/shape/shape
import nuance/collisions/all
import nuance/materials/material

{.warning[Deprecated]: off.}

type Primitive*[S: Scalar] = ref object of RootObj

method `$`*[S](prim: Primitive[S]): string {.base.} =
    "<BasePrimative>"

method world_bounds*[S](primitive: Primitive[S]): Bounds[3, S] {.base.} =
    return Bounds[3, S]()

method get_collisions*[S](primitive: Primitive[S], ray: Ray[3, S]): CollisionResult[3, S] {.base gcsafe.} =
    return CollisionResult[3, S]()

method collides*[S](primitive: Primitive[S], ray: Ray[3, S]): bool {.base.} =
    return false

type
    GeometricPrimitive*[S] = object of RootObj
        shape*: Shape[S]
        material*: Material[S]

    PrimitiveScatteringResult*[S] = ref object
        collides*: bool
        t_hit*: S
        interaction*: SurfaceInteraction[3, 2, S]
        primitive*: GeometricPrimitive[S]

method `$`*[S](prim: GeometricPrimitive[S]): string =
    fmt"<GeometricPrimative shape={prim.shape} material={prim.material}>"

proc make*[S](T: type GeometricPrimitive, shape: Shape[S]): GeometricPrimitive[S] =
    GeometricPrimitive[S](shape: shape, material: Material[S]())

proc make*[S](T: type GeometricPrimitive, shape: Shape[S], mat: Material[S]): GeometricPrimitive[S] =
    GeometricPrimitive[S](shape: shape, material: mat)

method world_bounds*[S](primitive: GeometricPrimitive[S]): Bounds[3, S] =
    primitive.shape.world_bounds

method centroid*[S](primitive: GeometricPrimitive[S]): Point[3, S] =
    return S(0.5) * primitive.world_bounds.p_min + S(0.5) * primitive.world_bounds.p_max

method get_collisions*[S](primitive: GeometricPrimitive[S], ray: Ray[3, S]): ShapeCollisionResult[S] {.gcsafe.} =
    primitive.shape.get_collisions(ray)

method collides*[S](primitive: GeometricPrimitive[S], ray: Ray[3, S]): bool =
    primitive.shape.collides(ray)

type PrimitiveGroup*[S] = ref object of Primitive[S]
    primitives*: seq[GeometricPrimitive[S]]
    #primitives*: ptr UncheckedArray[GeometricPrimitive[S]]
    n_primitives*: int

proc new_group*[S](primitives: seq[GeometricPrimitive[S]]): PrimitiveGroup[S] =
    return PrimitiveGroup[S](
      primitives: primitives,
      n_primitives: len(primitives)
    )

method get_collisions*[S](group: PrimitiveGroup[S], ray: Ray[3, S]): PrimitiveScatteringResult[S] {.base gcsafe.} =
    var
        collides = false
        collision_result: PrimitiveScatteringResult[S]

    for idx in 0 ..< group.n_primitives:
        let primitive = group.primitives[idx]
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
    for idx in 0 ..< group.n_primitives:
        let primitive = group.primitives[idx]
        if primitive.collides(ray):
            return (true, idx)
    return (false, -1)
