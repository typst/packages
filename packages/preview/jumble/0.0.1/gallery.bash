#!/bin/bash

typst c --root=. --input theme=default gallery/readme_banner.typ gallery/readme_banner_default.svg
typst c --root=. --input theme=light gallery/readme_banner.typ gallery/readme_banner_light.svg
typst c --root=. --input theme=dark gallery/readme_banner.typ gallery/readme_banner_dark.svg