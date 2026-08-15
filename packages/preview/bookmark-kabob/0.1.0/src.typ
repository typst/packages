/* Copyright 2026 HackYardo

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

/* font: "New Computer Modern Math"
  optional, Typst CLI built-in

abbreviate:
  r, b, i = roman, bold, italic
  bi = bold and italic
  u, l = uppercase, lowercase
  b-i, u-l: which to choose
  ru-to-b: roman uppercase convert to bold ones

unicode private use area: (e000, f8ff)
all unicode used:
  English b i bi letters: 0x1d5d4, 0x1d66f
  Greek b i bi letters: 0x1d6a8, 0x1d74e
  Arabic b numbers: 0x1d7ce, 0x1d7d7

DATA that directly deal with:
  language: (
    r u range,
    r l range,
    b start, diff of u l move to r,
    b i bi switch length, b u length) */

#let D = (
  en: (
    0x41, 0x5b,
    0x61, 0x7b,
    0x1d5d4, 0x06,
    0x34, 0x1a),
  el: (
    0x391, 0x3aa,
    0x3b1, 0x3ca,
    0x1d6a8, 0x06,
    0x3a, 0x1a),
  ar: (
    0x30, 0x3a,
    0x00, 0x00,
    0x1d7ce, 0x00,
    0x0a, 0x0a))

#let func(lang, formula, hex, b-i) = {
  let V = D.at(lang)
  let f = (
    ru-to-b: hex + V.at(4) - V.at(0) + V.at(6) * b-i,
    r-to-b: hex + V.at(4) - V.at(0),
    b-to-r: hex + V.at(0) - V.at(4),
    pre-bul-to-r: calc.rem(hex + 1 - V.at(4), V.at(6)))
  
  f.insert("rl-to-b", f.at("ru-to-b") - V.at(5))
  
  let pre = f.at("pre-bul-to-r")
  f.insert(
    "bul-to-r",
    pre + calc.quo(pre, V.at(7)) * V.at(5) + V.at(0) - 1)

  return str.from-unicode(f.at(formula))}


#let style(string, b-i) = {
  let new = ""
  let hex = 0x00
  for chr in string {
    hex = str.to-unicode(chr)
    if hex in range(0x61, 0x7b) {
      new = new + func("en", "rl-to-b", hex, b-i)}
    else if hex in range(0x41, 0x5b) {
      new = new + func("en", "ru-to-b", hex, b-i)}
    else if hex in range(0x391, 0x3aa) {
      new = new + func("el", "ru-to-b", hex, b-i)}
    else if hex in range(0x3b1, 0x3ca) {
      new = new + func("el", "rl-to-b", hex, b-i)}
    else if hex in range(0x30, 0x3a) and b-i != 0x01 {
      new = new + func("ar", "r-to-b", hex, b-i)}
    else {
      new = new + chr}}
  return new}

#let kabob(string) = {
  let i = string.at(0)
  let j = string.at(1)
  let string = string.trim(regex("[*_]"), at:start)
  if i + j in "_*_" {
    strong(emph(style(string, 0x02)))}
  else if i == "_" {
    emph(style(string, 0x01))}
  else if i == "*" {
    strong(style(string, 0x00))}
  else {
    string}}

#let ascii(chr) = {
  let new = chr
  let hex = str.to-unicode(chr)
  if hex in range(0x1d5d4, 0x1d670) {
    new = func("en", "bul-to-r", hex, 0x00)}
  else if hex in range(0x1d6a8, 0x1d74f) {
    new = func("el", "bul-to-r", hex, 0x00)}
  else if hex in range(0x1d7ce, 0x1d7d8) {
    new = func("ar", "b-to-r", hex, 0x00)}
  else {none}
  return new}

#let bobak(compose) = {
  let all = "[\u{1d5d4}-\u{1d7ff}]"
  show heading: h => {
    show regex(all): r => ascii(r.text)
    h}
  show outline: o => {
    show regex(all): r => ascii(r.text)
    o}
  compose}
