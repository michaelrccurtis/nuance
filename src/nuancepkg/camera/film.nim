import simplePNG except Pixel
import math
import std/[strformat, logging]
import nuancepkg/la/point
import nuancepkg/la/vector
import nuancepkg/la/bounds
import nuancepkg/colour/all

type
    Pixel* = object
        xyz*: array[3, float]

    Film* = ref object
        full_resolution*: Point[2, int]
        pixel_bounds*: Bounds[2, int]
        pixels: ptr UncheckedArray[Pixel]

proc `$`*(pixel: Pixel): string =
    result = "<Pxel:" & $pixel.xyz & ">"

proc width*(film: Film): int =
    film.pixel_bounds.diagonal.x

proc height*(film: Film): int =
    film.pixel_bounds.diagonal.y

proc get_pixel*(film: Film, x, y: int): var Pixel =
    let idx = (film.width * y) + x
    result = film.pixels[][idx]

proc `[]`*(film: Film, x, y: int): var Pixel =
    get_pixel(film, x, y)

proc init_pixels*(film: Film) =
    var
        memory = alloc(film.pixel_bounds.surfaceArea * sizeof(Pixel))
        pixels = cast[ptr UncheckedArray[Pixel]](memory)
    for idx in 0 ..< film.pixel_bounds.surfaceArea:
        pixels[idx] = Pixel(
          xyz: [0.0, 0.0, 0.0]
        )
    film.pixels = pixels

template deref(T: typedesc[ref|ptr]): typedesc =
  typeof(default(T)[])

proc `=destroy`*(flm: var deref(Film)) =
    if flm.pixels != nil:
        dealloc(flm.pixels)

proc new_film*(
  full_resolution: Point[2, int]): Film =
    let cropWindow = newBounds(
      Pt2(0.0, 0.0),
      Pt2(1.0, 1.0),
    )
    let pixel_bounds =
        newBounds(
          Pt2[int](
            ceil(float(full_resolution.x) * cropWindow.pMin.x).int,
            ceil(float(full_resolution.y) * cropWindow.pMin.y).int
            ),
            Pt2[int](
              ceil(float(full_resolution.x) * cropWindow.pMax.x).int,
              ceil(float(full_resolution.y) * cropWindow.pMax.y).int
            )
        )

    result = Film(
      full_resolution: full_resolution, pixel_bounds: pixel_bounds
    )

proc save_png*(film: Film, filename: string) =
    var scale = 1

    if film.width < 500:
        scale = int(ceil(500/film.width))

    info(fmt"outputting png at {scale}x scale")

    var png_file = init_pixels(film.width * scale, film.height * scale)
    png_file.fill(255, 255, 255, 255)

    for x in 0 ..< film.width:
        for y in 0 ..< film.height:
            let rgb = film[x, y].xyz
            for idx in 0 ..< scale:
                for idy in 0 ..< scale:
                    png_file.get_pixel(x*scale + idx, y * scale + idy).setColor(rgb_to_byte(rgb[0]), rgb_to_byte(rgb[1]), rgb_to_byte(rgb[2]), (255).uint8)

    for pix in png_file.items:
        if pix.r < 0 or pix.g < 0 or pix.b < 0 or pix.a < 0:
            echo "error"

    simplePNG(filename, png_file)
