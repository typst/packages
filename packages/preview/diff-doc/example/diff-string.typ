#import "@preview/js:0.1.3": *
#import "../lib.typ": *

#show: js

#let a = "hello, workd. こんばんは"
#let b = "hello, world. こんにちは"

#diff-string(a, b)
