import os
import std/[strformat, times, random, math, logging, isolation]
import threading/smartptrs
import strutils
import sequtils
import cligen
import malebolgia
import nuance/la/all
import nuance/camera/all
import nuance/collisions/all
import nuance/scene/all
import nuance/materials/all
import nuance/shape/all
import nuance/colour/all
import nuance/progress

# Configure logging
var logger = new_console_logger(fmtStr = "\e[0;35m[nuance]\e[0m $time - \e[32m$levelname\e[0m: ")
add_handler(logger)


# Initiate random seed
randomize()


var progress_channel: Channel[tuple[thread_id: int, progress:float, complete: bool]]


proc get_scene_collisions(scene: Scene[float], ray: Ray[3, float], use_bvh: bool = false): PrimitiveScatteringResult[float] =
    if use_bvh:
        return scene.bvh_root.get_collisions(ray)

    return scene.primative_group.get_collisions(ray)

proc ray_colour(ray: Ray[3, float], scene: Scene[float], depth: int, max_depth: int = 50, use_bvh: bool = false): Colour {.gcsafe.} =
    if depth > max_depth:
        return Black()

    let col = get_scene_collisions(scene, ray, use_bvh)

    if col.collides:
        let t_interaction = col.primitive.shape.object_to_world(col.interaction)
        let scattering = col.primitive.material.scatter(ray, t_interaction)
        if scattering.scattered:
            return scattering.attenuation * ray_colour(scattering.scattered_ray, scene, depth+1, use_bvh=use_bvh)
        return Black()
    let t = 0.5 * (norm(ray.d).y + 1.0)
    result = t*Vec3(1.0, 1.0, 1.0) + (1-t)*Vec3(0.5, 0.7, 1.0)


proc sample_film[S](scene: Scene[S], cam: PerspectiveCamera[S], x, y, samples: int, use_bvh: bool): Colour =
    result = Vec3(0.0, 0.0, 0.0)

    for s in 0 ..< samples:
        let ray = cam.generate_ray(
            CameraSample[S](
              pFilm: Pt2(S(x) + rand(1.0), S(y) + rand(1.0)),
              time: 0.5
            )
        )
        result += ray_colour(ray, scene, 0, use_bvh=use_bvh)


proc preview[S](group: PrimitiveGroup[S], cam: PerspectiveCamera[S], x, y : int): Colour =
    let ray = cam.generate_ray(
        CameraSample[S](
            pFilm: Pt2(S(x), S(y)),
            time: 0.5
        )
    )

    let 
        col = group.collides(ray)
        clr = float(col.index + 1) / float(group.n_primitives)

    result = Colour(arr:[clr, clr, clr])

proc write_patch_to_film[S](
    thread_id: int,
    scene: SharedPtr[Scene[S]],
    cam: SharedPtr[PerspectiveCamera[S]],
    samples_per_pixel: int,
    thread_ranges: SharedPtr[seq[Bounds[2, int]]],
    preview: bool = false,
    use_bvh: bool = false
): seq[seq[Colour]] {.thread.}=
    
    let bounds = thread_ranges[][thread_id]
    result = newSeqWith(bounds.p_max.x - bounds.p_min.x, newSeqWith(bounds.p_max.y - bounds.p_min.y, Vec3(0.0, 0.0, 0.0)))

    for x in bounds.p_min.x ..< bounds.p_max.x:
        let progress = float(x - bounds.p_min.x) / float(bounds.p_max.x - bounds.p_min.x)
        progress_channel.send((thread_id, progress, false))
        for y in bounds.p_min.y ..< bounds.p_max.y:
            if preview:
                result[x-bounds.p_min.x][y-bounds.p_min.y] = preview(scene[].primative_group, cam[], x, y)
            else:
                result[x-bounds.p_min.x][y-bounds.p_min.y] = sample_film(scene[], cam[], x, y, samples_per_pixel, use_bvh)
    
    progress_channel.send((thread_id, 1.0, true))


type ParallelStrategy = enum
    ps_x_blocks, ps_samples

proc nuance(scene_path: string, resolution = 10, samples_per_pixel = 50, threads = 10, parallel_strategy = ParallelStrategy.ps_samples, preview=false, bvh=false) =

    info("Welcome to nuance!")

    let
        ratio = 16.0 / 9.0
        height = resolution
        width = int(ratio * float(height))

    info(fmt"loading scene from {scene_path}")
    var scene = load_scene(scene_path)

    info("creating camera")
    let cam = new_perspective_camera(
        camera_to_world = inverse(LookAt(
            Pt3(3.0, 5.0, 1.0),
            Pt3(-1.0, 0.5, 0.0),
            Vec3(0.0, 0.0, 1.0)
        )),
        shutter_open = 0.0, shutter_close = 1.0,
        screen_window = new_bounds(Pt2(-ratio, -1.0), Pt2(ratio, 1.0)),
        lens_radius = 0.0, focal_distance = 1.0e6, fov = 45.0,
        full_resolution=Pt2[int](width, height)
    )

    let scene_ptr = newSharedPtr(scene)
    let cam_ptr = newSharedPtr(cam)

    if preview:
        info("rendering preview")

    info("main render start")
    var time = getTime()

    info(fmt"spawning {threads} threads with strategy {parallel_strategy}")

    var samples_per_pixel_per_thread = samples_per_pixel
    var total_samples_per_pixel = samples_per_pixel

    if preview:
        total_samples_per_pixel = 1

    if parallel_strategy == ParallelStrategy.ps_samples:
        if preview:
            samples_per_pixel_per_thread = 1
            total_samples_per_pixel = threads
        else:
            samples_per_pixel_per_thread = int(samples_per_pixel / threads)
            total_samples_per_pixel = threads * samples_per_pixel_per_thread
        debug(fmt"parallel_strategy samples per thread {samples_per_pixel_per_thread}")

    var scale = 1.0 / float(total_samples_per_pixel)

    var
        thread_ranges = newSeq[Bounds[2, int]](threads)
        outputs = newSeq[seq[seq[Colour]]](threads)
        running_threads = 0

    for thread in 0 .. thread_ranges.high:
        if parallel_strategy == ParallelStrategy.ps_x_blocks:
            let 
                block_size = int(ceil(width / threads))
                bounds = Bounds[2, int](
                    p_min: Pt2[int](block_size*thread, 0),
                    p_max: Pt2[int](block_size*(thread+1), height)
                )
                thread_bounds = bounds.intersect(cam_ptr[].film.pixel_bounds)
            debug(fmt"parallel_strategy x block size {block_size}")
            thread_ranges[thread] = thread_bounds

        if parallel_strategy == ParallelStrategy.ps_samples:
            thread_ranges[thread] = cam_ptr[].film.pixel_bounds

    progress_channel.open()

    var m = createMaster()
    let thread_ranges_ptr = newSharedPtr(thread_ranges)

    if bvh:
        info("using BVH")

    {.warning[Effect]:off.}
    m.awaitAll:
        for t in 0 ..< threads:
            debug(fmt"spawning thread {t+1} / {threads}")
            let thread_bounds = thread_ranges[t]
            
            if not cam_ptr[].film.pixel_bounds.overlaps(thread_bounds):
                debug(fmt"thread {t+1} not spawned: bounds {thread_bounds} do not overlap with film")
                break

            debug(fmt"thread {t+1}: {thread_bounds}")

            m.spawn write_patch_to_film(
                t,
                scene_ptr,
                cam_ptr,
                samples_per_pixel_per_thread,
                thread_ranges=thread_ranges_ptr,
                preview=preview,
                use_bvh=bvh
            ) -> outputs[t]
            running_threads += 1

        var threads_complete = 0
        let progress = MultiThreadProgressBar.make(running_threads)

        while true:
            progress.display()

            let listen = progress_channel.tryRecv()
            if listen.dataAvailable:
                progress.update(listen.msg.thread_id, listen.msg.progress * 100)

                if listen.msg.complete:
                    threads_complete += 1
                
            if threads_complete == running_threads:
                progress.finish()
                break

    {.warning[Effect]:on.}

    scale *= running_threads / threads

    progress_channel.close()

    var output_results = newSeq[seq[seq[Colour]]](threads)

    var dt = getTime() - time
    info(fmt"main render complete in {dt}")

    time = getTime()

    cam_ptr[].film.init_pixels()

    for t in 0 ..< threads:
        let thread_bounds = thread_ranges[t]

        if not cam_ptr[].film.pixel_bounds.overlaps(thread_bounds):
            break

        proc write(output: seq[seq[Colour]]) =
            for x in 0 ..< thread_bounds.p_max.x  - thread_bounds.p_min.x:
                for y in 0 ..< thread_bounds.p_max.y - thread_bounds.p_min.y:
                    for idx in 0 ..< 3:
                        cam_ptr[].film[x, y].xyz[idx] += scale * output[x][y][idx]
                
        # Avoids copying - much faster than output = ^outputs[t] for large outputs
        debug(fmt"Writing output from thread {t+1}")
        write(outputs[t])

    dt = getTime() - time
    info(fmt"writing to film complete in {dt}")

    if not dirExists("./output"):
        create_dir("./output")
    let
        ts = now().utc
        file = splitFile(scene_path)

    info("Saving png")
    if preview:
        cam_ptr[].film.save_png(fmt"./output/{file[1]}_preview_{ts}.png")
    else:
        cam_ptr[].film.save_png(fmt"./output/{file[1]}_{ts}.png")

    info("All done")

dispatch nuance
