#import "babel.typ": babel

// Based on the most used open-source licenses:
// https://libraries.io/licenses
// https://spdx.org/licenses/
// https://tldrlegal.com/
// https://choosealicense.com/licenses/
// https://www.synopsys.com/blogs/software-security/top-open-source-licenses/
// https://opensource.org/licenses/alphabetical

/// List of licenses. Note that this is _not_ identical to `best_of.license.LICENSES`.
/// The first one in `names` is the canonical name, usually SPDX ID.
/// And for simplicity, we don't distinguish between *-or-later and *-only.
#let _licenses = (
  (
    human: "MIT License",
    names: ("MIT",),
    url: "https://choosealicense.com/licenses/mit/",
  ),
  (
    human: "Apache License 2.0",
    names: ("Apache-2.0", "Apache-2"),
    url: "https://choosealicense.com/licenses/apache-2.0/",
  ),
  (
    human: "ISC License",
    names: ("ISC",),
    url: "https://choosealicense.com/licenses/isc/",
  ),
  (
    human: "BSD 3-Clause “New” or “Revised” License",
    names: ("BSD-3-Clause", "BSD-3", "BSD-3.0-Clause"),
    url: "https://choosealicense.com/licenses/bsd-3-clause/",
  ),
  (
    human: "BSD 2-Clause “Simplified” License",
    names: ("BSD-2-Clause", "BSD-2", "freebsd"),
    url: "https://choosealicense.com/licenses/bsd-2-clause/",
  ),
  (
    human: "BSD Zero Clause License",
    names: ("0BSD",),
    url: "https://choosealicense.com/licenses/0bsd/",
  ),
  (
    human: "GNU General Public License v3.0",
    names: ("GPL-3.0", "GPL3", "GPL-3", "GPLv3", "GPL-3.0-or-later", "GPL-3.0-only"),
    url: "https://choosealicense.com/licenses/gpl-3.0/",
    risky: true,
  ),
  (
    human: "GNU General Public License v2.0",
    names: ("GPL-2.0", "GPL-2"),
    url: "https://choosealicense.com/licenses/gpl-2.0/",
    risky: true,
  ),
  (
    human: "GNU Lesser General Public License v3.0",
    names: ("LGPL-3.0", "LGPL-3"),
    url: "https://choosealicense.com/licenses/lgpl-3.0/",
    risky: true,
  ),
  (
    human: "GNU Affero General Public License v3.0",
    names: ("AGPL-3.0", "AGPL-3", "AGPL-3.0-or-later", "AGPL-3.0-only"),
    url: "https://choosealicense.com/licenses/agpl-3.0/",
    risky: true,
  ),
  (
    human: "Mozilla Public License 2.0",
    names: ("MPL-2.0", "MPL-2"),
    url: "https://choosealicense.com/licenses/mpl-2.0/",
  ),
  (
    human: "The Unlicense",
    names: ("Unlicense",),
    url: "https://choosealicense.com/licenses/unlicense/",
  ),
  (
    human: "Eclipse Public License 2.0",
    names: ("EPL-2.0", "EPL-2"),
    url: "https://choosealicense.com/licenses/epl-2.0/",
  ),
  (
    human: "European Union Public License 1.2",
    names: ("EUPL-1.2",),
    url: "https://choosealicense.com/licenses/eupl-1.2/",
  ),
  (
    human: "Creative Commons Attribution-ShareAlike 4.0 International",
    names: ("CC BY-SA 4.0", "CC-BY-SA-4.0"),
    url: "https://creativecommons.org/licenses/by-sa/4.0/",
  ),
)

/// Normalize a license into (URL, name, human, warning).
#let get-license(query) = {
  if query.starts-with(regex("https?://")) {
    return (
      url: query,
      name: babel(en: "Custom", zh: "自编"),
      title: babel(en: "Warning: a custom license", zh: "警告：自编了许可证"),
      warning: true,
    )
  }
  for l in _licenses {
    if (l.names + (l.human,)).map(n => lower(n)).contains(lower(query)) {
      return if l.at("risky", default: false) {
        (
          url: l.url,
          name: l.names.first(),
          title: l.human + babel(en: " (Warning: risky license)", zh: "（警告：许可证有风险）"),
          warning: true,
        )
      } else {
        (
          url: l.url,
          name: l.names.first(),
          title: l.human,
          warning: false,
        )
      }
    }
  }
  return (
    url: none,
    name: query,
    title: babel(en: "Warning: an unknown license", zh: "警告：许可证未知"),
    warning: true,
  )
}
