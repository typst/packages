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

## Usage Instructions

### Online Web App

#### Create Project

- Open [![svg of typst-tongjithesis](https://img.shields.io/badge/Typst-paddling--tongji--thesis-239dae)](https://www.overleaf.com/latex/templates/tongji-university-undergraduate-thesis-template/tfvdvyggqybn) and click `Create project in app`.

- Or select `Start from a template` in the [Typst Web App](https://typst.app), then choose `paddling-tongji-thesis`.

#### Upload Fonts

Download all font files from the [`fonts` branch](https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst/tree/fonts) and upload them to the root directory of the project in the Typst Web App. You can then start using the template.

### Local Usage

#### 1. Install Typst

Follow the [Typst official documentation](https://github.com/typst/typst?tab=readme-ov-file#installation) to install Typst.

#### 2. Download Fonts

Download all font files from the [`fonts` branch](https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst/tree/fonts) and **install them on your system**.

#### Initialization using `typst`

##### Initialize Project

```bash
typst init @preview/paddling-tongji-thesis
```

##### Compile

```bash
typst compile main.typ
```

#### Initialization using `git clone`

##### Git Clone Project

```bash
git clone https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst.git
cd tongji-undergrad-thesis-typst
```

##### Compile

```bash
typst compile init-files/main.typ --root .
```

> [!TIP]
> If you don't want to install the fonts used by the project on your system, you can specify the font path during compilation, for example:
>
> ```bash
> typst compile init-files/main.typ --root . --font-path {YOUR_FONT_PATH}
> ```

## How to Contribute to This Project?

Please see [How to pull request](CONTRIBUTING.md/#how-to-pull-request).

## Open Source License

This project is licensed under the [MIT License](LICENSE).

### Disclaimer

This project uses fonts from the FounderType font library, with copyright belonging to FounderType. This project is for learning and communication purposes only and must not be used for commercial purposes.

## Acknowledgments for Outstanding Contributions

- This project originated from [FeO3](https://github.com/seashell11234455)'s initial version project [tongji-undergrad-thesis-typst](https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst/tree/lky).
- Later, [RizhongLin](https://github.com/RizhongLin) improved the template to better meet the requirements of Tongji University undergraduate thesis, and added basic tutorials for Typst.

We are very grateful to the above contributors for their efforts, which have provided convenience and help to more students.

When using this template, if you find this project helpful for your graduation project or thesis, we hope you can express your thanks and respect in your acknowledgments section.

## Acknowledgments for Open Source Projects

We have learned a lot from the excellent open-source projects of top universities:

- [lucifer1004/pkuthss-typst](https://github.com/lucifer1004/pkuthss-typst)
- [werifu/HUST-typst-template](https://github.com/werifu/HUST-typst-template)

## Contact

```python
# Python
[
    'rizhonglin@$.%'.replace('$', 'epfl').replace('%', 'ch'),
]
```
### QQ Group

- TJ-CSCCG Communication Group: `1013806782`