#import nimprof
import std/[strformat, times, logging]
import nuancepkg/la/all
import nuancepkg/shape/all
import nuancepkg/collisions/all

# Configure logging
var logger = newConsoleLogger(fmtStr = "\e[0;35m[nuance benchmark]\e[0m $time - \e[32m$levelname\e[0m: ")
addHandler(logger)

when isMainModule:
    let
        mesh = TriangleMesh[float].init(
          Translate(Vec3(0.0, 0.0, -1.0)),
          1, [0, 1, 2],
          3, [Pt3(0.0, 0.0, 0.0), Pt3(1.0, 0.0, 0.0), Pt3(0.0, 1.0, 0.0)]
        )
        tri = Triangle[float].init(
          Translate(Vec3(0.0, 0.0, -1.0)), inverse(Translate(Vec3(0.0, 0.0, -1.0))), false,
          mesh, 0
        )
        r_tri = new_ray(Pt3(0.1, 0.1, 0.0), Vec3(0.0, 0.0, -1.0))
        
        sph = new_sphere(1.0, Translate(Vec3(-2.0, 0.0, 0.0)))
        r_sph = new_ray(Pt3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0))

        cyl = new_cylinder(1.5, -1.0, 1.5, Translate(Vec3(0.0, 2.0, 0.0)))
        r_cyl = new_ray(Pt3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0))

    var time = cpuTime()
    for i in 0..(10000):
        discard collides(tri, r_tri)
    info(fmt"Time taken for tri collides: {cpuTime() - time}") 

    time = cpuTime()
    for i in 0..(10000):
        discard get_collisions(tri, r_tri)
    info(fmt"Time taken to get tri collisions: {cpuTime() - time}")

    time = cpuTime()
    for i in 0..(10000):
        discard collides(sph, r_sph)
    info(fmt"Time taken for sphere collides: {cpuTime() - time}") 

    time = cpuTime()
    for i in 0..(10000):
        discard get_collisions(sph, r_sph)
    info(fmt"Time taken to get sphere collisions: {cpuTime() - time}")

    let bounds = sph.object_bounds
    time = cpuTime()
    for i in 0..(10000):
        discard collides(bounds, r_sph)
    info(fmt"Time taken to get sphere bounds collisions: {cpuTime() - time}")

    time = cpuTime()
    for i in 0..(10000):
        discard collides(cyl, r_cyl)
    info(fmt"Time taken for cylinder collides: {cpuTime() - time}") 

    time = cpuTime()
    for i in 0..(10000):
        discard get_collisions(cyl, r_cyl)
    info(fmt"Time taken to get cylinder collisions: {cpuTime() - time}")
