import nuance/la/vector
import simplePNG except Pixel
import nimPNG
import utils

type
    Image* = ref object
        width*, height*: int
        pixels: ptr UncheckedArray[array[3, float]]

proc get_pixel*(img: Image, x, y: int): Colour =
    let idx = (img.width * y) + x
    result = Colour(arr: [
        img.pixels[][idx][0], img.pixels[][idx][1], img.pixels[][idx][2]
    ])

proc `[]`*(img: Image, x, y: int): Colour =
    get_pixel(img, x, y)

proc make*(T: type Image, png: PNGResult[string]): Image =
    var
        memory = allocShared(png.width * png.height * sizeof(array[3, float]))
        pixels = cast[ptr UncheckedArray[array[3, float]]](memory)

    for idx in 0 ..< png.width * png.height:
        pixels[idx][0] = char_to_rgb(png.data[idx*4 + 0])
        pixels[idx][1] = char_to_rgb(png.data[idx*4 + 1])
        pixels[idx][2] = char_to_rgb(png.data[idx*4 + 2])

    result = Image(
        width: png.width,
        height: png.height,
        pixels: pixels
    )

template deref(T: typedesc[ref|ptr]): typedesc =
    typeof(default(T)[])

proc `=destroy`*(img: deref(Image)) =
    if img.pixels != nil:
        deallocShared(img.pixels)
