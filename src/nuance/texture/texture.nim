import nuance/la/shared_vector
import nuance/collisions/interaction
import nuance/colour/all

{.warning[Deprecated]: off.}

type
    Texture*[S: Scalar] = ref object of RootObj


method `$`*[S](text: Texture[S]): string {.base.} =
    "<BaseTexture>"

method interaction_colour*[S](text: Texture[S], interaction: SurfaceInteraction[3, 2, S]): Colour {.base gcsafe.} =
    result = White()
