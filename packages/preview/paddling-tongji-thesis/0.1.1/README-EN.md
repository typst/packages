
# :page_facing_up: Tongji University Undergraduate Thesis Typst Template (STEM)

[中文](README.md) | English

> [!CAUTION]
> Since the Typst project is still in the development stage and support for some features is not perfect, there may be some issues with this template. If you encounter problems while using it, please feel free to submit an issue or PR and we will try our best to solve it.
>
> In the mean time, we also welcome you to use [our $\LaTeX$ template](https://github.com/TJ-CSCCG/tongji-undergrad-thesis).

## Sample Display

Below are displayed in order the "Cover", "Chinese Abstract", "Table of Contents", "Main Content", "References", and "Acknowledgments".

<p align="center">
      <img src="https://media.githubusercontent.com/media/TJ-CSCCG/TJCS-Images/tongji-undergrad-thesis-typst/preview/main_page-0001.jpg" width="30%">
      <img src="https://media.githubusercontent.com/media/TJ-CSCCG/TJCS-Images/tongji-undergrad-thesis-typst/preview/main_page-0002.jpg" width="30%">
      <img src="https://media.githubusercontent.com/media/TJ-CSCCG/TJCS-Images/tongji-undergrad-thesis-typst/preview/main_page-0004.jpg" width="30%">
      <img src="https://media.githubusercontent.com/media/TJ-CSCCG/TJCS-Images/tongji-undergrad-thesis-typst/preview/main_page-0005.jpg" width="30%">
      <img src="https://media.githubusercontent.com/media/TJ-CSCCG/TJCS-Images/tongji-undergrad-thesis-typst/preview/main_page-0019.jpg" width="30%">
      <img src="https://media.githubusercontent.com/media/TJ-CSCCG/TJCS-Images/tongji-undergrad-thesis-typst/preview/main_page-0020.jpg" width="30%">
</p>

## How to Use

### Online Web App

Please open [https://typst.app/universe/package/tongji-undergrad-thesis](https://typst.app/universe/package/tongji-undergrad-thesis) and click `Create project in app` , or choose `Start from a template`in the Web App, and choose `tongji-undergrad-thesis`.

And then, please upload **all** fonts from [https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst/tree/fonts/fonts](https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst/tree/fonts/fonts) to the root directory of the project in the Web App.

### Local - With typst init

#### 1. Install Typst

Refer to the [Typst](https://github.com/typst/typst?tab=readme-ov-file#installation) official documentation for installation.

#### 2. Init the project from the template

```bash
typst init @preview/tongji-undergrad-thesis
```

#### 3. Download Fonts

Please download the font files from the [`fonts`](https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst/tree/fonts) branch of this repository and install the font files to your system.

#### 4. Compile

Modify related files as needed, then execute the following command to compile.

```bash
typst compile main.typ
```

> [!TIP]
> If you find that the fonts are not displayed properly, please install the fonts to your system and then execute the compile command.

### Local - With git clone

#### 1. Install Typst

Refer to the [Typst](https://github.com/typst/typst?tab=readme-ov-file#installation) official documentation for installation.

#### 2. Clone this project

```bash
git clone https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst.git
cd tongji-undergrad-thesis-typst
```

#### 3. Download Fonts

Please download the font files from the [`fonts`](https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst/tree/fonts) branch of this repository and place them in the `fonts` folder, or install the font files to your system.

#### 4. Compile

Modify related files in `init-files` as needed, then execute the following command to compile.

```bash
typst --font-path ./fonts compile init-files/main.typ --root .
```

> [!TIP]
> If you find that the fonts are not displayed properly, please install the font files in the `fonts` folder to your system and then execute the compile command.

## How to Contribute to This Project?

Please see [How to pull request](CONTRIBUTING.md/#how-to-pull-request).

## Open Source License

This project is licensed under the [MIT License](LICENSE).

### Disclaimer

This project uses fonts from the FounderType font library, with copyright belonging to FounderType. This project is for learning and communication purposes only and must not be used for commercial purposes.

## Acknowledgments for Outstanding Contributions

* This project originated from [FeO3](https://github.com/seashell11234455)'s initial version project [tongji-undergrad-thesis-typst](https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst/tree/lky).
* Later, [RizhongLin](https://github.com/RizhongLin) improved the template to better meet the requirements of Tongji University undergraduate thesis, and added basic tutorials for Typst.

We are very grateful to the above contributors for their efforts, which have provided convenience and help to more students.

When using this template, if you find this project helpful for your graduation project or thesis, we hope you can express your thanks and respect in your acknowledgments section.

## Acknowledgments for Open Source Projects

We have learned a lot from the excellent open-source projects of top universities:

* [lucifer1004/pkuthss-typst](https://github.com/lucifer1004/pkuthss-typst)
* [werifu/HUST-typst-template](https://github.com/werifu/HUST-typst-template)

## Contact

```python
# Python
[
    'rizhonglin@$.%'.replace('$', 'epfl').replace('%', 'ch'),
]
```