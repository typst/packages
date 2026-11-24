# Styling a `blog` site

thyme ships one look, but it is a default, not a lock-in. There are four levels of
customization. Each one goes further than the one before, and you only need the
first that does the job.

| Level | What you change | Where |
| --- | --- | --- |
| 1. `theme:` | palette (light and dark), font stacks, self-hosted fonts, PDF page | `blog.site(theme: (...))` |
| 2. Design tokens | type scale, measure, spacing, radius, links, code chips | CSS variables in your stylesheet |
| 3. Your own rules | anything, on the stable class names below | your stylesheet |
| 4. No thyme CSS | the whole design | `blog.site(base-stylesheet: false)` |

Add your stylesheet with `blog.site(stylesheets: (path("site.css"),))`. It is copied
into the bundle and linked on every page, after thyme's.

## Why your rules always win

Every thyme rule sits in one cascade layer, `@layer thyme`. Rules outside a layer
beat layered rules whatever their specificity. So `h2 { border: none }` in your
stylesheet beats thyme's `article.numbered-sections h2`. No `!important`, no copied
selectors.

One caveat from CSS itself: inside layers, `!important` is reversed, so thyme's few
`!important` rules (print layout, reduced motion) beat an `!important` of yours. Use
plain rules.

## 1. `theme:`

The theme dictionary sets the palette and the fonts for both HTML and paged output
(PDF). See `theme-default` in `src/blog/theme.typ` for every key, for example:

```typst
#show: blog.site.with(
  theme: (
    paper-light: oklch(98%, 0.01, 90deg),
    text-light: oklch(20%, 0.02, 260deg),
    sans-fonts: ("Inter",),
    font-base: "/fonts/",
  ),
)
```

## 2. Design tokens

Set any of these on `:root` in your stylesheet. The defaults are thyme's look.

| Token | Default | Controls |
| --- | --- | --- |
| `--bg`, `--fg`, `--muted`, `--line`, `--frame`, `--surface-1`, `--surface-2` | from `theme:` | colours (light and dark resolved for you) |
| `--serif`, `--sans`, `--mono`, `--math` | from `theme:` | font stacks |
| `--body-font` | `var(--serif)` | running text |
| `--heading-font` | `var(--serif)` | `h1` to `h6` |
| `--heading-weight` | `600` | headings and entry titles |
| `--body-size` | `var(--step-0)` | running text size |
| `--body-leading` | `1.66` | running text line height |
| `--step--2` … `--step-3` | fluid `clamp()` scale | the type scale every size uses |
| `--title-size` | `var(--step-3)` | the homepage title (`main.home > h1`) |
| `--title-tracking` | `-0.03em` | its letter spacing |
| `--page-title-size` | `var(--step-3)` | every other `h1` (posts, pages, tags) |
| `--entry-title-size` | `var(--step-0)` | titles on entry cards |
| `--section-rule` | `1px solid var(--line)` | the rule under `h2` (`none` removes it) |
| `--page-max` | `76rem` | the page width, sidenote margin included |
| `--page-padding` | fluid | the space around the page |
| `--measure` | `62%` | the reading column; the rest is the sidenote margin |
| `--page-padding-narrow`, `--measure-narrow` | `2rem 1.25rem 3.5rem 1.25rem`, `44rem` | the same below 1100px (sidenotes fold into the text) |
| `--topbar-space` | `1.4rem` | space under the top bar |
| `--radius` | `3px` | code chips, code blocks, boxes |
| `--link-thickness`, `--link-underline` | `1px`, 42 % of `--fg` | link underlines |
| `--scroll-fade` | `3rem` | how far a wide table fades out at the edge where more of it is |
| `--code-size`, `--code-bg`, `--code-border` | `0.84em`, `--surface-1`, `1px solid var(--line)` | inline code chips |

A narrower `--measure` leaves more room for sidenotes. Below 1100px the sidenotes
fold into the text and the column is `--measure-narrow` wide.

Example, a sans-serif site with a wider column and no heading rules:

```css
:root {
  --body-font: var(--sans);
  --heading-font: var(--sans);
  --heading-weight: 500;
  --measure: 70%;
  --section-rule: none;
}
```

## 3. Your own rules: stable class names

These names are part of the API. They change only with a minor version and a
CHANGELOG entry.

| Selector | What it is |
| --- | --- |
| `main.home` | the homepage `main` (its first `h1` is the site title) |
| `nav.back-home`, `.site-nav`, `.top-actions`, `.source-link` | the top bar: backlink or `nav:` links, language switch, `.typ` link |
| `footer.site-footer`, `ul.links` | `blog.site(footer: ...)`, `links(...)` |
| `ul.entries`, `.entry`, `.entry-head`, `.entry-title`, `.reading`, `time.when`, `.entry-summary` | entry cards (`#post(...)`, `#posts()`, tag pages) |
| `header.article-header`, `.article-subtitle`, `dl.post-props`, `.prop-tag` | the head of a post |
| `article.numbered-sections` | a post with numbered `h2` |
| `.sidenote`, `.sidenote-number`, `.margin-toggle` | sidenotes |
| `ul.tag-cloud`, `.tag-count` | `/tags/` |
| `.blog-wide`, `.blog-table`, `.blog-crosstab` | wide blocks and tables (a wide table scrolls sideways) |
| `.expressive-code`, `.ec-line`, `.gutter`, `.ln`, `.code`, `.code-lang`, `.copy-button` | code blocks |
| `.blog-toc`, `.blog-post-nav` | table of contents, older/newer links |
| `.blog-proof`, `.blog-qed`, `.blog-sbox` | proofs and statement boxes |
| `.blog-diagram` | diagrams |

## 4. No thyme CSS

`blog.site(base-stylesheet: false)` emits no `css/style.css` and links only your
`stylesheets`. The HTML stays the same, so the class names above are your hooks.
Paged output (PDF) is not affected; it never used the stylesheet.
