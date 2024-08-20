import nuance/la/vector

type Colour* = Vector[3, float]

proc make*(T: type Colour, r, g, b: float): Colour =
    result = Colour(arr: [r, g, b])

proc Black*(): Colour =
    result = Colour(arr: [0.0, 0.0, 0.0])

proc White*(): Colour =
    result = Colour(arr: [1.0, 1.0, 1.0])

proc xyz_to_rgb*(xyz: Colour): Colour =
    xyz

# Todo: actually use luminescence rather than rgb values
#proc xyz_to_rgb*(xyz: Colour): Colour =
#    Colour.make(
#        3.240479 * xyz[0] - 1.537150 * xyz[1] - 0.498535 * xyz[2],
#        -0.969256 * xyz[0] + 1.875991 * xyz[1] + 0.041556 * xyz[2],
#        0.055648 * xyz[0] - 0.204043 * xyz[1] + 1.057311 * xyz[2],
#    )

#proc rgb_to_xyz*(rgb: Colour): Colour =
#    Colour.make(
#      0.412453 * rgb[0] + 0.357580 * rgb[1] + 0.180423 * rgb[2],
#      0.212671 * rgb[0] + 0.715160 * rgb[1] + 0.072169 * rgb[2],
#      0.019334 * rgb[0] + 0.119193 * rgb[1] + 0.950227 * rgb[2],
#    )

proc rgb_to_byte*(v: float): uint8 =
    clamp(255.0 * v + 0.5, 0.0, 254.0).uint8

proc char_to_rgb*(v: char): float =
    clamp(float(v) / 255.0, 0.0, 1.0)
