// Public entrypoint for `@preview/thyme:0.1.0`.
//
// Only what a site author writes by hand is re-exported here. The helpers that the
// engine and the presets use to build a site (slugs, plain-text extraction, tree walks,
// language resolution, feed and sitemap construction) are module-level functions in
// `src/`. Import a module directly when you need one; the paths are stable even though
// the names are not part of the public surface.
//
// `site` is always the core engine. The blog preset ships its own bundler as
// `blog.site`, so the two never collide and import order never matters.

#import "blog/mod.typ" as blog

// Building a site.
#import "core.typ": backlinks, file, mount, site, webpage


// One document in several languages.
#import "i18n.typ": tr

// A starting point for a `robots.txt` you then own.
#import "seo.typ": robots-txt
