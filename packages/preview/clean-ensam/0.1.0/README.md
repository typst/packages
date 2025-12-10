# Clean Doc Template (Typst)

A simple, clean, and customizable template for ENSAM RABAT needs.

**Disclaimer**: This template is in **no way shape or form affiliated with UM5 or ENSAM RABAT**
This is an **unofficial document** designed to help you quickly get up to speed with your work at ENSAM RABAT and is **in no way affiliated with the school.**

![Page de garde](images/example.png)

## Features

- Clean layout
- Easy customization
- Ready for articles, reports, and notes

## Usage

## Quick start

```c
#import "@preview/clean-ensam:0.1.0": project

#show: project.with(
  title: "Etude d'une vulnérabilité critique",
  subtitle: "React2Shell (CVE-2025-55182)",
  authors: (
    "BAHLAOUI Ahmed",
  ),
  supervisor: "Pr. X",
  department: "MAGI",
  program: "INDIA/SD",
  module: "Programmation web avancée",
  year: "2025-2026",
)
```

### 1. Install Typst

Make sure you have Typst installed from https://typst.app

### 2. You can use this template in the web-version of Typst

### 3. Use template locally:

Once you have typst installed and ready to use, simply follow the steps:

First clone the github repository

```bash
git clone https://github.com/ahmed-bahlaoui/clean-ensam.git
```

Then create the following directory and copy all contents of clean-ensam to it

```bash
mkdir -p  ~\AppData\Roaming\typst\packages\preview\clean-ensam\0.1.0\
mv clean-ensam\* ~\AppData\Roaming\typst\packages\preview\clean-ensam\0.1.0\
rm clean-ensam
```

You're now good to go!

```bash
typst init @preview/clean-ensam:0.1.0
```
