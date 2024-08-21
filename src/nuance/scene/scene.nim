import primitive
import bvh_tree

type Scene*[S] = ref object of RootObj
    primative_group*: PrimitiveGroup[S]

    bvh_root*: BVHNode[S]