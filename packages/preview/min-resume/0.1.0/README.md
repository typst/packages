# Minimal Résumé

<center>
  Simple and professional résumé for professional people
</center>


# Quick Start

```typst
#import "@preview/min-resume:0.1.0": resume
#show: manual.resume(
  name: "Your Name",
  title: "Academic Title and/or Main Occupation",
  photo: image("photo.png"),
  personal: "Relevant personal info",
  birth: (1997, 05, 19),
  address: "Your Address (no street nor house number)",
  email: "example@email.com",
  phone: "+1 (000) 000-0000",
)
```


# Description

Generate a modern and direct to the point résumé, fit for today's Human Resources
demands of assertiveness. There is no colorful designs, figures, creative fonts,
nor anything that diverts attention when reading the document: is just plain old
black sans-serif text in white paper. In fact, if one sees only the resulting
résumé, may say it was written in Word — but it was written with all of
Typst's benefits and conveniences.

The package was written by a Brazilian, so it uses some common Brazilian
practices when writing a résumé — but it is simple and minimalistic, even to
Brazilian standards. Therefore, if some information are missing or  unnecessary
to you, feel free to adapt it to your needs.


# More Information

- [Official manual](https://raw.githubusercontent.com/mayconfmelo/min-resume/refs/tags/0.1.0/docs/pdf/manual.pdf)
- [Example PDF result](https://raw.githubusercontent.com/mayconfmelo/min-resume/refs/tags/0.1.0/docs/pdf/example.pdf)
- [Example Typst code](https://github.com/mayconfmelo/min-resume/blob/0.1.0/template/main.typ)
- [Changelog](https://github.com/mayconfmelo/min-resume/blob/main/CHANGELOG.md)