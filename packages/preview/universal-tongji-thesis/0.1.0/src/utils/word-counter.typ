/*
 * word-counter.typ
 *
 * @project: modern-ecnu-thesis
 * @author: Juntong Chen (dev@jtchen.io)
 * @created: 2025-01-11 13:37:30
 * @modified: 2025-01-12 16:21:32
 *
 * Copyright (c) 2025 Juntong Chen. All rights reserved.
 */

#import "@preview/wordometer:0.1.4": *

#let word-count-cjk(content, ..options) = {
  let stats = word-count-of(content, exclude: (heading), counter: s => (
    characters: s.replace(regex("\s+"), "").clusters().len(),
    words: s.matches(regex("\b[\w'’.,\-]+\b")).len(),
    words-cjk: s.matches(regex("[\p{Han}]|[\p{Latin}'’.,\-]+")).len(),
  ), ..options)
  state("total-words-cjk").update((prev) => prev + stats.words-cjk)
  state("total-words").update((prev) => prev + stats.words)
  state("total-characters").update((prev) => prev + stats.characters)
  content
}

#let total-words = context state("total-words-cjk").final()
#let total-characters = context state("total-characters").final()