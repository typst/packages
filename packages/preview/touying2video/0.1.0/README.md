# touying2video

The tools converts a touying-typ presentation slide to a presentation video with voice over. 
It is currently in its proof-of-concept stage.
To use this tool, import `p2vmeta.typ` in your Typst file.  ~~Currently, it only works with a patched version of `touying-typ`.~~ (No longer needed, as we have found a workaround.)  The file to import (`p2vmeta.typ`) is available in the `demo` directory.  A demo video is available at <https://youtu.be/lJ7X57xG7V8>.


## Quick start

A demo file is available at `demo/demo.typ`.   To use the tool, add the following lines at the beginning of your Typst file:

```typst
#import "@preview/touying:0.6.1": *
// #import "p2vmeta.typ": *     // The typst portion of the tool
#import "@preview/touying2video:0.1.0": *

#t2sdefaults(                // Set the default settings for the tool
  transition: "fade",
  transition_duration: 0.8,
)

#pdfpc.config(// You may also set defaults for the pdfpc module in touying-typ
  disable-markdown: false,
  default-transition: (
    type: "fade",
    duration-seconds: 1,
  ),
)

#import themes.university: *

#import "@preview/numbly:0.1.0": numbly

#show: university-theme.with(
    // ... The setting for your theme
)
```

**Very import**: At the end of your Typst file, add the following lines:

```typst
#context t2s-file(here())
```

After compiling the Typst file, run the following command to generate the video:

```bash
python main.py path/to/your/typst/file.typ
```


## Reference

The following tags are provided:
- `t2sdefaults`: the default settings for the tool
    - `duration_logical`: the duration of each (physical) slide in seconds
    - `transition`: the transition effect between slides, currently, only `"fade"` and `"none"` are supported
    - `transition_duration`: the duration of the transition effect in seconds, if the transition is set to `"none"`, this parameter must be 0. 
- `t2s`: the content of speech
    - By default, a transition to a new slide with a speech will not happen until the current speech finishes.
- `duration`: the duration of the slide in seconds
    - `logical`: the duration of the (logical) slide in seconds
        - Please note that this parameter will behave funny when you have a speech in the slide that is not starting at the first physical slide of this logical slide.
    - `physical`: the duration of each (physical) slide in seconds
        - The following special values are allowed:
            - `"fk"`, i.e., `f` followed by an integer: until the finish of the k-th speech in the logical slide, k starts from 1
            <!-- - `"fk+t"`, i.e., `f` followed by an integer, a `+`, and a float: until the finish of the k-th speech in the logical slide plus the specified time-->
    - Note that, the time specified here is more similar to "minimal time", because the tool will wait for the speech to finish before transitioning to the next slide (if the next slide has a speech)
- `video-overlay`
    - `start`: in which physical slide in this logical slide that the video overlay starts
    - All dimensions can be in pixels or percentage of the slide size
    - one of width or height can be negative, in which case, the size is calculated from the other dimension, preserving the aspect ratio of the video
        - if both are negative, the video is not resized
    - Currently, typst and touying do not support putting a video in the presentation slides.  However, we provide a method to insert video clips in the presentation video. 


## Video overlay in the presentation video


Example:

```typst
      video-overlay(
        start_from: 2,
        video: "img/animations/video1.mp4",
        x: 20%,   // relative to the slide width
        y: 40%,   // relative to the slide height
        width: 18%, // relative to the slide width
      )
```


## License

[aGPL-3.0](https://github.com/yangwenbo99/touying2video/blob/main/LICENSE)
