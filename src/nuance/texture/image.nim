import nuance/la/shared_vector
import nuance/la/point
import nuance/collisions/interaction
import nuance/colour/all
import texture
import nimPNG

{.warning[Deprecated]: off.}

type
    ImageTexture*[S: Scalar] = ref object of Texture[S]
        image*: Image
        # Todo: consider setting a mapping type for uv transforms

method `$`*[S](text: ImageTexture[S]): string =
    "<ImageTexture>"


method interaction_colour*[S](text: ImageTexture[S], interaction: SurfaceInteraction[3, 2, S]): Colour =
    let uv = interaction.uv

    # use a basic map from uv to the images
    # note that the below conversion for u coords needed given left handed assumptions about coordinate system
    # v coord conversion to move bottom <-> top
    result = text.image[int((1.0 - uv[0])*float(text.image.width)), int((1.0 - uv[1])*float(text.image.height))]
