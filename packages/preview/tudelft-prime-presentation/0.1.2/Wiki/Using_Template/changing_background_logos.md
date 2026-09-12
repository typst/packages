# Backgrounds and Logos

- A **background** is a picture (usually in either `jpg` or `png` format) that we use as the background for the title silde.

- A **logo** is a sqaure picture (usually in either `jpg`, `png` or `svg` format) that we use on the top-left side of the title slide, just left to the title.

## Default Backgrounds and Logos


The template provides a background and a few logos that can be used.

- The backgrounds can be found in
    ```
    assets/Common/background
    ```
- The logos can be found 
    ```
    assets/Common/{subject}/Logos
    ```

In version `0.1.2` of this template, we include three subjects:

- `Linear Algebra`
- `Calculus`
- `ProbStats` (Probability and Statistics)

## Using Default Backgrounds and Logos

To use the default backgrounds and logos, we need to specify the path (as a string) when showing the `prime-slides`:

```typst
#import "@preview/tudelft-PRIME-presentation:0.1.2": * 

#show: prime-slides.with(
    title: "Linear Algebra Lecture 5",
    subtitle: "Matrix operations",
    background : "background/background.png",
    logo : "Linear Algebra/Logos/intersection_planes.png"
)
```

Observe that we use the following structure for:

- `background: "background/{picture_name}.{extension}"`
- `logo: "{subject}/Logos/{logo_name}.{extension}"`

This setup is fine for working with the currently available subjects.

## Using Custom Backgrounds and Logos

When developing materials for a new course, we would like to use different backgrounds and logos than
the ones available (at least until they are included into the template).


The dimensions of the background should be:

- width: 33.9cm
- height: 19.05cm

For the logos, they should be squared, with size:

- height: 4.11cm

To use new pictures and templates, we need to first create an image object for the logo and one for the background,
and then pass it to `prime-slides`. Check the example below:

```typst
#import "@preview/tudelft-PRIME-presentation:0.1.2": * 

#let background_image = image("my_background_image.png", width: 33.9cm, height: 19.05cm)
#let logo_image = image("my_logo.png", height: 4.11cm)

#show: prime-slides.with(
    title: "Lecture XY",
    subtitle: "Topic Z",
    background : background_image,
    logo : logo_image
)

```

This will create a new presentation with the custom backgrounds and logos.
