import material
import nuancepkg/collisions/interaction
import nuancepkg/la/all
import nuancepkg/texture/all
import nuancepkg/colour/all

{.warning[Deprecated]: off.}

type Metal*[S: Scalar] = ref object of Material[S]
    albedo*: Texture[S]

method `$`*[S](mat: Metal[S]): string {.base.} =
    "<Metal>"

method scatter*[S](mat: Metal[S], ray: Ray[3, S], interaction: SurfaceInteraction[3, 2, S]): MaterialScatterResult[S] =

    let
        scattered_d = reflect(norm(ray.d), to_vector(interaction.n))
        scattered_ray = interaction.new_ray(scattered_d)

    return MaterialScatterResult[S](
        scattered: dot(scattered_ray.d, to_vector(interaction.n)) > 0,
        attenuation: mat.albedo.interaction_colour(interaction),
        scattered_ray: scattered_ray
    )
