// Public surface of the `blog` preset.
//
// Only the names a post or a site file calls by hand are re-exported. Everything else
// here is module-level: the theme plumbing, the upstream components `blog` wraps, and
// the pieces the bundler applies itself.
//
// Every `blog` module imports its real dependencies from `../core.typ`, `theme.typ` and
// so on, so this file is a list of exports and nothing else.

#import "../core.typ": backlinks, file, mount, webpage

#import "theme.typ": theme-default

#import "notes.typ": mcite, mn, sidenote, sn

#import "components.typ": (
  callout, codeblock, corollary, definition, diagram, epigraph, example, grid-table, hr, important-box, kbd, lemma,
  links, note-box, proof, proposition, recipe, remark, sbox, tablem, theorem, three-line-table, tip-box, toc,
  warning-box, wide, zebraw,
)

#import "post.typ": post

#import "site.typ": posts, site

//   engine      site, webpage, mount, file, backlinks
//   theme       theme-default
//   notes       sidenote, sn, mn, mcite
//   blocks      callout, codeblock, sbox, academic environments
//               (definition, theorem, lemma, proposition, corollary, example,
//               recipe, remark, proof), note-box, tip-box, warning-box,
//               important-box, epigraph, wide, diagram, kbd, hr, links, toc
//   tables      tablem, three-line-table, grid-table, zebraw
//   posts       post, posts
//
// Applied for you, and therefore not exported:
//
//   post-nav    `blog.site(post-nav: true)` puts it under every post.
//   tag-cloud   `blog.site` builds the `/tags/` index and the per-tag archives.
//   post-asset  a post's `assets: ((name, bytes),)` parameter does the same job.
//   with-html-math   applied by the page shell.
//
// `checklist`, `showybox`, `zebraw-init` and `zebraw-themes` are `@preview` packages
// that `blog` wraps. Import them from their own package when you need them directly.
