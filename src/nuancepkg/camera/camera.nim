import nuancepkg/la/point
import nuancepkg/la/transform
import film

type
    CameraSample*[S] = ref object of RootObj
        p_film*, p_lens*: Point[2, S]
        time*: S

    Camera*[S] = ref object of RootObj
        camera_to_world*: Transform[4, 4, S]
        shutter_open*, shutter_close*: S
        film*: Film
