# [Social Media References based on Font Awesome for Typst](https://github.com/Bi0T1N/typst-iconic-salmon-fa)
The `iconic-salmon-fa` package is designed to help you create your curriculum vitae (CV). It allows you to easily reference your social media profiles with the typical icon of the service plus a link to your profile.  
The package name is a combination of the acronym *SociAL Media icONs* and the word *iconic* because all these icons have an iconic design (and iconic also contains the word *icon*).

## Features
- Support for popular social media, developer and career platforms
- Uniform design for all entries
- Based on the Internet's icon library [Font Awesome](https://fontawesome.com/)
- Easy to use
- Allows the customization of the look (extra args are passed to [`text`](https://typst.app/docs/reference/text/text/))

## Fonts Installation
### Linux
1. [Download Font Awesome for Desktop](https://fontawesome.com/download)
2. Unzip the file
3. Switch into the `otfs` folder within the unzipped folder
4. Run `mkdir -p /usr/share/fonts/truetype/`
5. Run `install -m644 'Font Awesome 6 Brands-Regular-400.otf' /usr/share/fonts/truetype/`
6. Unfortunately not all brands are included in the brands font file, so you must also run `install -m644 'Font Awesome 6 Free-Regular-400.otf' /usr/share/fonts/truetype/`

## Usage
### Using Typst's package manager
You can install the library using the [typst packages](https://github.com/typst/packages):
```typst
#import "@preview/iconic-salmon-fa:1.1.0": *
```

### Install manually
Put the `iconic-salmon-fa.typ` file in your project directory and import it:
```typst
#import "iconic-salmon-fa.typ": *
```

### Minimal Example
```typst
// #import "@preview/iconic-salmon-fa:1.1.0": github-info, gitlab-info
#import "iconic-salmon-fa.typ": github-info, gitlab-info

This project was created by #github-info("Bi0T1N"). You can also find me on #gitlab-info("GitLab", rgb("#811052"), url: "https://gitlab.com/Bi0T1N").
```

### Examples
See the [`examples.typ`](examples/examples.typ) file for a complete example. The [generated PDF files](examples/) are also available for preview.

## Troubleshooting
### Icons are not displayed correctly
Make sure that you have installed the required Font Awesome ligature-based font files.

## Contribution
Feel free to open an issue or a pull request if you find any problems or have any suggestions.

## License
This library is licensed under the MIT license. Feel free to use it in your project.

## Trademark Disclaimer
Product names, logos, brands and other trademarks referred to in this project are the property of their respective trademark holders.  
These trademark holders are not affiliated with this Typst library, nor are the authors officially endorsed by them, nor do the authors claim ownership of these trademarks.
