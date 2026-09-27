# medieval-resume

A simple resume / CV theme, based on <https://github.com/xyz-yuanhf/yuan-resume> and others.

[Documentation](https://git.filmroellchen.eu/filmroellchen/myresume/src/branch/main/manual.pdf)

[Example Resume](https://git.filmroellchen.eu/filmroellchen/myresume/src/branch/main/template/main.pdf) ([source](template/main.typ))

Use the example resume as a starting point:

```shell
typst init '@preview/medieval-resume'
```

## Conversion and differences from LaTeX myresume.cls

This was originally a modified and improved version of yuan-resume, still written in LaTeX, and named myresume.cls.
It was converted into Typst in 2026, while trying to keep the existing style as closely as possible.
Note that the commands to actually write the CV are significantly different between the previous LaTeX version and the Typst version.

Since some style parameters of the original, especially spacings and sizes, “just happened” or came from the `article` class default, not everything was able to be carried over 1-1. Furthermore, some (arguable) improvements to the layout were also done, especially since precise layouting is much easier in Typst than LaTeX. Some known visual differences to the modified version of myresume.cls (and therefore also yuan-resume) include:

- Vertical pipes for the job sections are slightly thicker and taller.
- List spacing, spacing between `#cv-section`s, paragraph line spacing (leading), header height, and more have been visually approximated any may be a few millimeters off.
- Date localization is more accurate, therefore using `lang: "en"` with this template produces different results than the English version of myresume.cls.
- All numbers in dates use tabular figures, which might not just change the digit kerning, but also their appearances (known to happen with Inter among others)
- Footnotes appear correctly on the bottom of the page, instead of in the middle of the page (which was a sideeffect of `\minipage`)
- Hyphenation has been disabled (often produces undesirable results)
- Phone number and Email address are now links
- Weird extra indentation of some kinds of CV sections is no longer present; all CV sections are correctly left-aligned to each other

## Fonts

This theme was designed around specific font families:

- [Calluna](https://fonts.adobe.com/fonts/calluna) as the header and footer font
- [Cronos](https://fonts.adobe.com/fonts/cronos) as the section title
- [Inter](https://rsms.me/inter/) as the sans-serif body font
- [Sabon](https://en.wikipedia.org/wiki/Sabon) as the serif body font

All of these fonts are freely available with permissive licenses, so you can use them for your personal documents.
In particular, Sabon is a 1960s Linotype font with lots of different digitizations.
I strongly recommend you to install the fonts from the provided links to achieve the best look with this package.
If the fonts are not available (and you’re not using custom fonts), the package will attempt to fall back to other defaults (see typst’s warnings).

As specified above, the theme is pre-configured with two font groups, one serif, and one sans-serif.
If you only want to use one of the two groups, the fonts from the other group obviously don’t have to be installed.

Of course, you can also override all fonts according to your personal preference.

## License

The theme is licensed under [MIT](LICENSE).

The template is public domain under the [Unlicense](https://unlicense.org).
