import nuance/la/point
import nuance/la/vector
import nuance/la/transform
import nuance/la/bounds
import camera
import film

type
    ProjectiveCamera*[S] = ref object of Camera[S]
        lens_radius*, focal_distance*: S
        camera_to_screen*, raster_to_camera*: Transform[4, 4, S]
        screen_to_raster*, raster_to_screen*: Transform[4, 4, S]

proc screen_to_raster[S](film: Film, screen_window: Bounds[2, S]): Transform[4, 4, S] =
    Scale(Vec3(S(film.full_resolution.x), S(film.full_resolution.y), S(1))) *
    Scale(Vec3(
      S(1) / (screen_window.p_max.x - screen_window.p_min.x),
      S(1) / (screen_window.p_min.y - screen_window.p_max.y),
      S(1)
    )) *
    Translate(Vec3(-screen_window.p_min.x, -screen_window.p_max.y, S(0)))

proc init*[S](T: typedesc[ProjectiveCamera[S]],
  camera_to_world, camera_to_screen: Transform[4, 4, S],
  screen_window: Bounds[2, S], shutter_open, shutter_close: S,
  lens_radius, focal_distance: S, film: Film
): auto =

    let
        screen_to_raster = screen_to_raster(film, screen_window)
        raster_to_screen = inverse(screen_to_raster)
        raster_to_camera = inverse(camera_to_screen) * raster_to_screen

    return T(
      camera_to_world: camera_to_world,
      camera_to_screen: camera_to_screen,
      shutter_open: shutter_open,
      shutter_close: shutter_close,
      lens_radius: lens_radius,
      focal_distance: focal_distance,
      screen_to_raster: screen_to_raster,
      raster_to_screen: raster_to_screen,
      raster_to_camera: raster_to_camera,
      film: film
    )
