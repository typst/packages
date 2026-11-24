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
  booktab, callout, codeblock, corollary, crosstab, definition, diagram, epigraph, example, hr, important, kbd, lemma,
  links, note, proof, proposition, recipe, remark, sbox, tablem, theorem, tip, toc, warning, wide, zebraw,
)

#import "post.typ": post

#import "site.typ": posts, site

//   engine      site, webpage, mount, file, backlinks
//   theme       theme-default
//   notes       sidenote, sn, mn, mcite
//   blocks      callout, codeblock, sbox, academic environments
//               (definition, theorem, lemma, proposition, corollary, example,
//               recipe, remark, proof), note, tip, warning,
//               important, epigraph, wide, diagram, kbd, hr, links, toc
//   tables      tablem, booktab, crosstab, zebraw
//   posts       post, posts
//
// Applied for you, and therefore not exported:
//
//   post-nav    `blog.site(post-nav: true)` puts it under every post.
//   nav         `blog.site(nav: ("/", "/posts/", "/tags/"))` puts section links
//               in the top bar in place of `/..`.
//   tag-cloud   `blog.site` builds the `/tags/` index and the per-tag archives.
//   post-asset  a post's `assets: ((name, bytes),)` parameter does the same job.
//   show-reading   `blog.site(show-reading: true)` puts the estimated minutes
//                 (`<n> min`) beside the title on every entry card; the date
//                 stays alone on the right edge.
//   with-html-math   applied by the page shell.
//
// `checklist`, `showybox`, `zebraw-init` and `zebraw-themes` are `@preview` packages
// that `blog` wraps. Import them from their own package when you need them directly.
