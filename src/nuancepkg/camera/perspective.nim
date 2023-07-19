import math
import nuancepkg/la/transform
import nuancepkg/la/ray
import nuancepkg/la/point
import nuancepkg/la/vector
import nuancepkg/la/bounds
import nuancepkg/math/utils
import film
import camera
import projective

type
    PerspectiveCamera*[S] = ref object of ProjectiveCamera[S]
        dx_camera*, dy_camera*: Vector[3, S]
        A: S

proc new_perspective_camera*[S](
  camera_to_world: Transform[4, 4, S],
  screen_window: Bounds[2, S],
  shutter_open,
  shutter_close: S,
  lens_radius,
  focal_distance,
  fov: S,
  film: Film,
): PerspectiveCamera[S] =

    var camera = PerspectiveCamera[float].init(
      camera_to_world,
      Perspective(fov, 1.0e-2, 1000.0),
      screen_window,
      shutter_open,
      shutter_close,
      lens_radius,
      focal_distance,
      film,
    )

    let res = film.full_resolution
    var
        p_min = camera.raster_to_camera(Pt3(S(0), S(0), S(0)))
        p_max = camera.raster_to_camera(Pt3(S(res.x), S(res.y), S(0)))

    camera.dx_camera = camera.raster_to_camera(Pt3(S(1), S(0), S(0))) - p_min
    camera.dy_camera = camera.raster_to_camera(Pt3(S(0), S(1), S(0))) - p_min

    p_min = p_min / p_min.z
    p_max = p_max / p_max.z

    camera.A = abs((p_max.x - p_min.x) * (p_max.y - p_min.y))
    return camera

proc concentric_sample_disc[S](u: Point[2, S]): Point[2, S] =
    let u_offset = S(2) * u - Vec2(S(1), S(1))

    if u_offset.x == 0 or u_offset.y == 0:
        return Pt2(S(0), S(0))

    var
        theta = S(0)
        r = S(0)

    if abs(u_offset.x) > abs(u_offset.y):
        r = u_offset.x
        theta = PI / 4 * (u_offset.y / u_offset.x)
    else:
        r = u_offset.y
        theta = PI / 2.0 - PI / 4.0 * (u_offset.x / u_offset.y)

    return r * Pt2(cos(theta), sin(theta))


proc generate_ray*[S](camera: PerspectiveCamera[S], sample: CameraSample): Ray[3, S] =
    let
        p_film = Pt3(sample.p_film.x, sample.p_film.y, S(0))
        p_camera = camera.raster_to_camera(p_film)

    var ray = Ray3(Pt3(S(0), S(0), S(0)), norm(to_vector(p_camera)))

    if camera.lens_radius > 0:
        let
            p_lens = camera.lens_radius * concentric_sample_disc(sample.p_lens)
            ft = camera.focal_distance / ray.d.z
            p_focus = ray(ft)

        ray.o = Pt3(p_lens.x, p_lens.y, S(0))
        ray.d = norm(p_focus - ray.o)
    ray.time = linear_interp(sample.time, camera.shutter_open, camera.shutter_close)
    return camera.camera_to_world(ray)
