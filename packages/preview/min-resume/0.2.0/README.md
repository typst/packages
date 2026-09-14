# Minimal Résumé

<div align="center">

<p class="hidden">
  Simple and professional résumé for professional people
</p>

<p class="hidden">
  <a href="https://typst.app/universe/package/min-resume">
    <img src="https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Fmin-resume&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=Universe&color=%23239DAE&labelColor=%23353c44" /></a>
  <a href="https://github.com/mayconfmelo/min-resume/tree/dev/">
    <img src="https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fmayconfmelo%2Fmin-resume%2Frefs%2Fheads%2Fdev%2Ftypst.toml&query=%24.package.version&logo=github&label=Development&logoColor=%2397978e&color=%23239DAE&labelColor=%23353c44" /></a>
</p>


[![Manual](https://img.shields.io/badge/Manual-%23353c44)](https://raw.githubusercontent.com/mayconfmelo/min-resume/refs/tags/0.2.0/docs/manual.pdf)
[![Example PDF](https://img.shields.io/badge/Example-.pdf-%23777?labelColor=%23353c44)](https://raw.githubusercontent.com/mayconfmelo/min-resume/refs/tags/0.2.0/docs/example.pdf)
[![Example SRC](https://img.shields.io/badge/Example-.typ-%23777?labelColor=%23353c44)](https://github.com/mayconfmelo/min-resume/blob/0.2.0/template/main.typ)
[![Changelog](https://img.shields.io/badge/Changelog-%23353c44)](https://github.com/mayconfmelo/min-resume/blob/main/docs/changelog.md)
[![Contribute](https://img.shields.io/badge/Contribute-%23353c44)](https://github.com/mayconfmelo/min-resume/blob/main/docs/contributing.md)


<p class="hidden">

[![Tests](https://github.com/mayconfmelo/min-resume/actions/workflows/tests.yml/badge.svg)](https://github.com/mayconfmelo/min-resume/actions/workflows/tests.yml)
[![Build](https://github.com/mayconfmelo/min-resume/actions/workflows/build.yml/badge.svg)](https://github.com/mayconfmelo/min-resume/actions/workflows/build.yml)
[![Spellcheck](https://github.com/mayconfmelo/min-resume/actions/workflows/spellcheck.yml/badge.svg)](https://github.com/mayconfmelo/min-resume/actions/workflows/spellcheck.yml)

</p>
</div>


## Quick Start

```typst
#import "@preview/min-resume:0.2.0": resume
#show: manual.resume(
  name: "Name",
  title: "Academic title and/or occupation",
  photo: image("photo.png"),
  personal: "Relevant personal info",
  birth: (1997, 05, 19),
  address: "Public address",
  email: "example@email.com",
  phone: "+1 (000) 000-0000",
)
```


## Description

Generate a modern and straightforward résumé that meets today's Human Resources
demands for assertiveness. There are no colorful designs, images, creative fonts,
or anything that distracts from reading the document: it's just plain black
sans-serif text on white paper. In fact, someone who sees only the resulting
résumé might think it was written in Word — but it was actually created with all
of Typst's benefits and conveniences.

The package was created with Brazilian trends and practices for Human Resources
in mind; thus, if any information is missing or unnecessary for you, feel free
to adapt it to your needs.


## Feature List

- Optional data
  - Academic title and/or main occupation
  - Personal information
  - Age (calculated from birth date)
  - Email (with _mailto:_ link)
  - Phone number (with WhatsApp link)
  - Photo
  - Linkedin profile QR Code
  - Professional letter
- Job experience & academic formation entries
  - Automatic time calculation
- Special inline lists
- Linkedin profile QR code
- YAML-generated document


## Default Fonts

**Text:**
[TeX Gyre Heros](https://www.gust.org.pl/projects/e-foundry/tex-gyre/heros/qhv2.004otf.zip) or
Arial

**Headings:**
[TeX Gyre Adventor](https://www.gust.org.pl/projects/e-foundry/tex-gyre/adventor/qag2_501otf.zip) or 
Century Gothic