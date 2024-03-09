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

## Examples

![Shape primitives](examples/sphere_cylinder_colours.png?raw=true "Shape primitives")
![Sun and Glass](examples/sun_and_glass.png?raw=true "Sun and Glass render")
![Globe reflection](examples/globe_reflection.png?raw=true "Globe reflection")

### Assets:

-   earth.png, sun.png courtesy of https://www.solarsystemscope.com/textures/
-   checker.png courtesy of https://www.oxpal.com/uv-checker-texture.html
-   Astronaut by Poly by Google [CC-BY] (https://creativecommons.org/licenses/by/3.0/) via Poly Pizza (https://poly.pizza/m/dLHpzNdygsg)
