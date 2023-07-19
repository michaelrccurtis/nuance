import std/[strformat, terminal]
import strutils

type MultiThreadProgressBar* = ref object
    progress: seq[float]
    finished: bool
    setup: bool


proc make*(T: type MultiThreadProgressBar, threads: int): MultiThreadProgressBar =
    var progress = newSeq[float](threads)

    for t in 0 ..< threads:
        progress[t] = 0

    result = MultiThreadProgressBar(
        progress: newSeq[float](threads),
        finished: false,
        setup: false
    )

proc total_progress(bar: MultiThreadProgressBar): float =
    result = 0.0
    for thread in 0 ..< bar.progress.high:
        result += bar.progress[thread] / float(bar.progress.high)

proc update*(bar: MultiThreadProgressBar, thread: int, progress: float) =
    bar.progress[thread] = progress

proc display*(bar: MultiThreadProgressBar) =
    if bar.setup:
        write(stdout, "\r")
    else:
        bar.setup = true

    var total_progress = bar.total_progress

    if bar.finished:
        total_progress = 100.0

    let
        terminal_width = terminalWidth()
        progress_bar_width = terminal_width - 30
        progress_width = int(float(progress_bar_width) * total_progress / 100)

        progress_string = "█".repeat(progress_width) & " ".repeat(progress_bar_width - progress_width)

    write(stdout, fmt"{int(total_progress):>3d}% |" & progress_string & "|")

    if bar.finished:
        write(stdout, "\n")

    flush_file(stdout)

proc finish*(bar: MultiThreadProgressBar) =
    bar.finished = true
    bar.display()
