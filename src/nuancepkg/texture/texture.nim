import nuancepkg/la/shared_vector
import nuancepkg/collisions/interaction
import nuancepkg/colour/all

{.warning[Deprecated]: off.}

type
    Texture*[S: Scalar] = ref object of RootObj


method `$`*[S](text: Texture[S]): string {.base.} =
    "<BaseTexture>"

method interaction_colour*[S](text: Texture[S], interaction: SurfaceInteraction[3, 2, S]) : Colour {.base.} =
    result = White()