> [!NOTE]
> This is the version of the readme adapted for the Github Readme.
  This adaption is less than ideal.
  If you want to copy text and have a faithful render, go to [this link](https://html-preview.github.io/?url=https://github.com/marc-thieme/frame-it/blob/assets/README.html).
## Introduction

[Frame-It](https://github.com/marc-thieme/frame-it) offers a
straightforward way to define and use custom environments in your
documents. Its syntax is designed to integrate seamlessly with your
source code.

Two predefined styles are included by default. You can also create
custom styling functions that use the same user-facing API while giving
you complete control over the Typst elements in your document.

<div id="frame-wrapper-1">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-0.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-0.svg"> </picture> 

</div>

In contrast:

<div id="frame-wrapper-2">

<figure>
<div id="frame-wrapper-3">
<div id="frame-wrapper-3">
 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-1.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-1.svg"> </picture> 
</div>
</div>
</figure>

</div>

The default styles are merely functions with the correct signature. If
they don't appeal to you, you have complete freedom to define custom
styling functions yourself.

<div id="frame-wrapper-5">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-2.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-2.svg"> </picture> 

</div>

## Quick Start

Import and define your desired frames:

    #import "@preview/frame-it:1.1.1": *

    #let (example, feature, variant, syntax) = frames(
      feature: ("Feature",),
      // For each frame kind, you have to provide its supplement title to be displayed
      variant: ("Variant",),
      // You can provide a color or leave it out and it will be generated
      example: ("Example", gray),
      // You can add as many as you want
      syntax: ("Syntax",),
    )
    // This is necessary. Don't forget this!
    #show: frame-style(styles.boxy)

How to use it is explained below. Here is a quick example:

    #example[Title][Optional Tag][
      Body, i.e. large content block for the frame.
    ]

which yields

<div id="frame-wrapper-6">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-3.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-3.svg"> </picture> 

</div>

## Feature List

The following features are demonstrated in all predefined styles.

### Seamlessly hightight parts of your document

<div id="frame-wrapper-7">

<div id="frame-wrapper-7">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-4.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-4.svg"> </picture> 

</div>

</div>

<div id="frame-wrapper-9">

<div id="frame-wrapper-9">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-5.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-5.svg"> </picture> 

</div>

</div>

<div id="frame-wrapper-11">

<div id="frame-wrapper-11">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-6.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-6.svg"> </picture> 

</div>

</div>

<div id="frame-wrapper-13">

<div id="frame-wrapper-13">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-7.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-7.svg"> </picture> 

</div>

</div>

<div id="frame-wrapper-15">

<div id="frame-wrapper-15">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-8.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-8.svg"> </picture> 

</div>

</div>

<div id="frame-wrapper-17">

<div id="frame-wrapper-17">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-9.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-9.svg"> </picture> 

</div>

</div>

For brief elements, use \[\] as the body to omit the content.

<div id="frame-wrapper-19">

<div id="frame-wrapper-19">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-10.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-10.svg"> </picture> 

</div>

</div>

### Highlight parts distinctively

<div id="frame-wrapper-21">

<div id="frame-wrapper-21">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-11.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-11.svg"> </picture> 

</div>

</div>

<div id="frame-wrapper-23">

<div id="frame-wrapper-23">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-12.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-12.svg"> </picture> 

</div>

</div>

<div id="frame-wrapper-25">

<div id="frame-wrapper-25">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-13.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-13.svg"> </picture> 

</div>

</div>

<div id="frame-wrapper-27">

<div id="frame-wrapper-27">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-14.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-14.svg"> </picture> 

</div>

</div>

<div id="frame-wrapper-29">

<div id="frame-wrapper-29">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-15.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-15.svg"> </picture> 

</div>

</div>

<div id="frame-wrapper-31">

<div id="frame-wrapper-31">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-16.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-16.svg"> </picture> 

</div>

</div>

For brief elements, use \[\] as the body to omit the content.

<div id="frame-wrapper-33">

<div id="frame-wrapper-33">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-17.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-17.svg"> </picture> 

</div>

</div>

### A third Alternative

We recently a third style, namely `styles.thmbox`:

<div id="frame-wrapper-35">

<div id="frame-wrapper-35">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-18.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-18.svg"> </picture> 

</div>

</div>

<div id="frame-wrapper-37">

<div id="frame-wrapper-37">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-19.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-19.svg"> </picture> 

</div>

</div>

<div id="frame-wrapper-39">

<div id="frame-wrapper-39">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-20.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-20.svg"> </picture> 

</div>

</div>

<div id="frame-wrapper-41">

<div id="frame-wrapper-41">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-21.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-21.svg"> </picture> 

</div>

</div>

<div id="frame-wrapper-43">

<div id="frame-wrapper-43">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-22.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-22.svg"> </picture> 

</div>

</div>

<div id="frame-wrapper-45">

<div id="frame-wrapper-45">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-23.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-23.svg"> </picture> 

</div>

</div>

For brief elements, use \[\] as the body to omit the content.

<div id="frame-wrapper-47">

<div id="frame-wrapper-47">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-24.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-24.svg"> </picture> 

</div>

</div>

### Miscallaneous

Internally, every frame is just a `figure` where the `kind` is set to
`"frame"` (or a different custom value). As such, most things that can
be done to a figure can be done with a frame as well. Whenever you would
like to do something custom but don't know if it is supported, try
achieving it with a normal figure first and then apply the same show
rule to your frames. Here is a list of examples:

<div id="frame-wrapper-49">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-25.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-25.svg"> </picture> 

</div>

<div id="frame-wrapper-50">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-26.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-26.svg"> </picture> 

</div>

<div id="frame-wrapper-51">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-27.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-27.svg"> </picture> 

</div>

<div id="frame-wrapper-52">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-28.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-28.svg"> </picture> 

</div>

<div id="frame-wrapper-53">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-29.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-29.svg"> </picture> 

</div>

<div id="frame-wrapper-54">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-30.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-30.svg"> </picture> 

</div>

## Custom Styling

Internally, there is nothing special about the predefined styles. The
only requirement for any styling function is to adhere to the following
function signature interface:

<div id="frame-wrapper-55">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-31.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-31.svg"> </picture> 

</div>

where `arg` is going to be the value passed behind the supplement for
each frame variant in the `frames` function. For the predefined styles,
this is the color of the frames. When defining your own styling
function, it has to have the following signature:

The content returned will be placed as–is in the document.

<div id="frame-wrapper-56">

 <picture> <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-dark-32.svg"> <img src="https://raw.githubusercontent.com/marc-thieme/frame-it/refs/heads/assets/README-svg-light-32.svg"> </picture> 

</div>

For more information on how to define your own styling function, please
look into the `styling` module.
