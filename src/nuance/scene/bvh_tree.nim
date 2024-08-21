import std/[algorithm, math]
import nuance/la/shared_vector
import nuance/la/point
import nuance/la/bounds
import nuance/la/ray
import primitive

type BVHNode*[S: Scalar] = ref object of RootObj
    is_leaf: bool
    bounds*: Bounds[3, S]
    child1*: BVHNode[S]
    child2*: BVHNode[S]
    split_axis: int
    primitives: seq[GeometricPrimitive[S]]

proc make_leaf_node*[S](primitives: seq[GeometricPrimitive[S]], bounds: Bounds[3, S]): BVHNode[S] = 
    return BVHNode[S](
        is_leaf: true,
        bounds: bounds,
        primitives: primitives,
    )

proc make_branch_node*[S](axis: int, child1: BVHNode[S], child2: BVHNode[S]): BVHNode[S] = 
    return BVHNode[S](
        is_leaf: false,
        bounds: union(child1.bounds, child2.bounds),
        split_axis: axis,
        child1: child1,
        child2: child2,
    )

proc centroid_cmp*[S](dim: int): proc(a: GeometricPrimitive[S], b: GeometricPrimitive[S]): int =
    proc cmp(a: GeometricPrimitive[S], b: GeometricPrimitive[S]): int =
        if a.centroid[dim] >= b.centroid[dim]:
            return 1
        return -1
    return cmp

proc split_primitives*[S](primitives: seq[GeometricPrimitive[S]], dim: int): (seq[GeometricPrimitive[S]],seq[GeometricPrimitive[S]]) =
    let
        mid: int = toInt(floor(len(primitives) / 2))
        ordered_primitives = sorted(primitives, centroid_cmp[S](dim))

    return (ordered_primitives[0..<mid], ordered_primitives[mid..<len(ordered_primitives)])

proc build_bvh*[S](primitives: seq[GeometricPrimitive[S]]): BVHNode[S] =
    var
        bounds = primitives[0].world_bounds
        centroid_bounds = new_bounds(primitives[0].centroid)

    if len(primitives) == 1:
        return make_leaf_node(primitives, primitives[0].world_bounds)

    for primitive in primitives[1..<len(primitives)]:
        bounds = union(bounds, primitive.world_bounds)
        centroid_bounds = union(centroid_bounds, primitive.centroid)

    let dim = maximum_extent(centroid_bounds)

    if centroid_bounds.p_max[dim] == centroid_bounds.p_min[dim]:
        return make_leaf_node(primitives, bounds)

    let (left, right) = split_primitives(primitives, dim)

    return make_branch_node(
        dim,
        build_bvh(left),
        build_bvh(right)
    )

proc get_collisions*[S](root: BVHNode[S], ray: Ray[3, S]): PrimitiveScatteringResult[S] {.gcsafe.} =
    if not root.bounds.collides(ray):
        return PrimitiveScatteringResult[S](collides: false)

    var
        collides = false
        collision_result: PrimitiveScatteringResult[S]

    if not root.is_leaf:
        let
            collision_result_1 = get_collisions(root.child1, ray)
            collision_result_2 = get_collisions(root.child2, ray)

        if collision_result_1.collides and collision_result_2.collides:
            if collision_result_1.t_hit < collision_result_2.t_hit:
                return collision_result_1    
            return collision_result_2

        if collision_result_1.collides:
            return collision_result_1

        if collision_result_2.collides:
            return collision_result_2

        return PrimitiveScatteringResult[S](collides: false)

    for primitive in root.primitives:
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
