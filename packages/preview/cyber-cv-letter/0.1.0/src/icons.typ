// Icon loading. Root-absolute paths here are the package's own internal
// asset references (never used for author-supplied content, which stays
// plain-relative — see the markup contract in the spec) — a leading "/"
// resolves against this package's own root regardless of the consuming
// workflow's --root.

#let icon-dir = "/icons/FontAwesome"

#let icon-path(name) = icon-dir + "/" + name + ".png"

// Sniffs a bare link domain (e.g. "github.com/sconnor") to pick an icon
// kind — also used as PDF/UA-1 alt text for the icon image.
#let icon-kind-for-link(url) = {
  if "github.com" in url {
    "github"
  } else if "linkedin.com" in url {
    "linkedin"
  } else {
    "website"
  }
}

#let icon-for-link(url) = icon-path(icon-kind-for-link(url))
