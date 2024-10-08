import nuance/la/shared_vector
import nuance/collisions/interaction
import nuance/la/ray
import nuance/colour/all

{.warning[Deprecated]: off.}

type
    Material*[S: Scalar] = ref object of RootObj
    MaterialScatterResult*[S: Scalar] = ref object
        scattered*: bool
        attenuation*: Colour
        scattered_ray*: Ray[3, S]


method `$`*[S](mat: Material[S]): string {.base.} =
    "<BaseMaterial>"

method scatter*[S](mat: Material[S], ray: Ray[3, S], interation: SurfaceInteraction[3, 2, S]): MaterialScatterResult[
        S] {.base gcsafe.} =
    result = MaterialScatterResult[S](scattered: false)
