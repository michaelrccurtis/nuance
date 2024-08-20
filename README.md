# Nuance

Nuance is a simple path tracer for nim. It is currently in development.

I built this to learn about both Nim and path tracing!

## Features

-   Material support for glass, metal & lambertian materials
-   Primitive support for spheres, triangle meshes, cylinders and dics
-   Texture support, including images
-   Parallelised rendering pipeline
-   Scene definition via a .toml style file

## In progress

-   Model support through .obj files

## Usage

nuance is run as a CLI:

```
  nuance [REQUIRED,optional-params]
```

It supports a number of command line options:

| Option                      | Type                        | Required? | Default    | Effect                                    |
| --------------------------- | --------------------------- | --------- | ---------- | ----------------------------------------- |
| `-s=, --scene-path=`        | `string`                    | Yes       |            | Path to the .nuance scene file            |
| `-r=, --resolution=`        | `int`                       | No        | 10         | Resolution                                |
| `--samples-per-pixel=`      | `int`                       | No        | 50         | Samples per pixel                         |
| `-t=, --threads=`           | `int`                       | No        | 10         | Threads to use                            |
| `-p=, --parallel-strategy=` | `ps-samples`, `ps_x_blocks` | No        | ps-samples | Select the strategy for parallelisation   |
| `--preview `                | `bool`                      | No        | false      | Whether to render a (very speedy) preview |

## Examples

![Shape primitives](examples/sphere_cylinder_colours.png?raw=true "Shape primitives")
![Sun and Glass](examples/sun_and_glass.png?raw=true "Sun and Glass render")
![Globe reflection](examples/globe_reflection.png?raw=true "Globe reflection")

### Assets:

-   earth.png, sun.png courtesy of https://www.solarsystemscope.com/textures/
-   checker.png courtesy of https://www.oxpal.com/uv-checker-texture.html
-   Astronaut by Poly by Google [CC-BY] (https://creativecommons.org/licenses/by/3.0/) via Poly Pizza (https://poly.pizza/m/dLHpzNdygsg)
