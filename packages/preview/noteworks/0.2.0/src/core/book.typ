// =====================================================
// BOOK - Explicit document assembly
// =====================================================
// The document entry point declares its own structure:
//
//   #show: noteworthy.with(title: "My Notes", theme: "aether")
//
//   #cover()
//   #preface[Welcome!]
//   #toc()
//
//   #chapter("Chapter Title", summary: [One-line description.])
//   #page("Page Title")[#include "content/1/1.typ"]
//   #page("Another Page")[#include "content/1/2.typ"]
//
// Chapter and page numbers are derived from document order:
// every chapter cover emits a <chapter-cover> anchor and every
// page emits a <nw-page> anchor, so inserting or reordering
// entries renumbers everything (including the TOC) automatically.

#import "setup.typ": format-chapter-id, format-page-id, nw-config
#import "../module/core/cover/mod.typ": chapter-cover, project

#let chapter(title, summary: none) = {
  chapter-cover(
    number: context {
      // The cover's own anchor sits above this text, so the count of
      // preceding anchors is this chapter's 1-based ordinal.
      let n = query(selector(<chapter-cover>).before(here())).len()
      let total = query(<chapter-cover>).len()
      nw-config().chapter-name + " " + format-chapter-id(n, total)
    },
    title: title,
    summary: summary,
  )
}

#let page(title, body) = {
  show: project.with(
    number: context {
      // Renders in the title block, before this page's own <nw-page>
      // anchor, so all counted anchors belong to earlier pages.
      let chapters = query(selector(<chapter-cover>).before(here()))
      let ch-n = chapters.len()
      let pages-in-chapter = if ch-n == 0 {
        query(selector(<nw-page>).before(here()))
      } else {
        query(selector(<nw-page>).after(chapters.last().location()).before(here()))
      }
      let pg-n = pages-in-chapter.len() + 1

      // Sibling count only drives the zero-pad width of the page part
      let siblings = if ch-n == 0 {
        query(<nw-page>).len()
      } else {
        let later = query(selector(<chapter-cover>).after(here()))
        if later.len() > 0 {
          query(selector(<nw-page>).after(chapters.last().location()).before(later.first().location())).len()
        } else {
          query(selector(<nw-page>).after(chapters.last().location())).len()
        }
      }
      let total-ch = query(<chapter-cover>).len()
      nw-config().chapter-name + " " + format-page-id(str(ch-n) + "." + str(pg-n), siblings, total-ch)
    },
    title: title,
  )
  [#std.metadata((title: title)) <nw-page>]
  body
}
