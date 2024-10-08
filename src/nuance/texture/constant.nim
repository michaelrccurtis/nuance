import nuance/la/shared_vector
import nuance/collisions/interaction
import nuance/colour/all
import texture

{.warning[Deprecated]: off.}

type
    ConstantTexture*[S: Scalar] = ref object of Texture[S]
        colour*: Colour


method `$`*[S](text: ConstantTexture[S]): string {.base.} =
    "<ContantTexture>"

method interaction_colour*[S](text: ConstantTexture[S], interaction: SurfaceInteraction[3, 2, S]): Colour =
    result = text.colour
