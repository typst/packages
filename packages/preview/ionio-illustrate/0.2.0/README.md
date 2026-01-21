<a name="readme-top"></a>

# The `ionio-illustrate` package
<div align="center">
<a href="https://github.com/jamesxx/ionio-illustrate/blob/master/LICENSE">
  <img alt="GitHub" src="https://img.shields.io/github/license/jamesxx/ionio-illustrate">
</a>
<a href="https://github.com/typst/packages/tree/main/packages/preview/ionio-illustrate">
  <img alt="typst package" src="https://img.shields.io/badge/typst-package-239dad">
</a>
<a href="https://github.com/JamesxX/ionio-illustrate/tags">
<img alt="GitHub tag (with filter)" src="https://img.shields.io/github/v/tag/jamesxx/ionio-illustrate">
</a>
</div>

This package implements a Cetz chart-like object for displying mass spectrometric data in Typst documents. It allows for individually styled mass peaks, callouts, titles, and mass callipers.
<br />
  <p align="center">
    <a href="https://github.com/jamesxx/ionio-illustrate/blob/main/manual.pdf"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/jamesxx/ionio-illustrate/issues">Report Bug</a>
    ·
    <a href="https://github.com/jamesxx/ionio-illustrate/issues">Request Feature</a>
  </p>
</div>

## Getting Started
To make use of the `ionio-illustrate` package, you'll need to add it to your project like shown below. Make sure you are importing a version that supports your end goal.

```typst
#import "@preview/ionio-illustrate:0.2.0": *
```

Then, load in your mass spectrum data and pass it through to the package like so. Data should be 2D array, and by default the mass-charge ratio is in the first column, and the relative intensities are in the second column.

```typst
#let data = csv("isobutelene_epoxide.csv")

#let ms = mass-spectrum(massspec, args: (
  size: (12,6),
  range: (0,100),
)) 

#figure((ms.display)())
```

![](gallery/isobulelene_epoxide.typ.png)

There are many ways to further enhance your spectrum, please check out the manual to find out how.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->
## Roadmap
- [x] Pass style options through to the plot (tracker: #1)
- [ ] Better placement of text depending on plot size
- [ ] Improve default step on axes
- [ ] Add support for callouts that are not immediately above their assigned peak
    - [ ] Automatically detect when two annotations are too close, and display accordingly
- [ ] Move to new Typst type system (waiting on upstream)
- [ ] Add in function for displaying skeletal structure of chemical
- [ ] Optional second axis for absolute intensity
- [ ] Add additional display functions
    - [ ] Figure out function signature for multiple data sets
    - [ ] Overlayed and shifted
    - [ ] Horizontal reflection
        - [ ] How to update existing extras?

See the [open issues](https://github.com/jamesxx/ionio-illustrate/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->
## License

Distributed under the MIT License. See <a href="https://github.com/jamesxx/ionio-illustrate/blob/master/LICENSE">`LICENSE`</a>  for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>


## Gallery
![](gallery/linalool.typ.png)

<p align="right">(<a href="#readme-top">back to top</a>)</p>