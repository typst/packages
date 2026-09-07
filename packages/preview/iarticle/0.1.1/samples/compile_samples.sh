#!/bin/sh -e

typst compile article-en.typ
typst compile article-ja.typ
typst compile report-en.typ
typst compile report-ja.typ
typst compile howto-support-i18n-en.typ
typst compile howto-support-i18n-ja.typ
