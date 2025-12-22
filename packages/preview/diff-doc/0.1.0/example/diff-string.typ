#import "@preview/js:0.1.3": *
#import "@preview/diff-doc:0.1.0": *

#show: js

#let a = "hello, workd. こんばんは"
#let b = "hello, world. こんにちは"

#diff-string(a, b)
