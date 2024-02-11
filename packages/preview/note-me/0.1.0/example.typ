// As the package hasn't been published, import it from local.
// Replace `local` to `preview` once the package is published.
#import "@local/note-me:0.1.0": *

#note[
Highlights information that users should take into account, even when skimming.
]

#tip[
Optional information to help a user be more successful.
]

#important[
Crucial information necessary for users to succeed.
]

#warning[
Critical content demanding immediate user attention due to potential risks.
]

#caution[
Negative potential consequences of an action.
]

#admonition(
  icon: "icons/stop.svg",
  color: color.fuchsia,
  title: "Custom Title",
)[
  The icon, color and title are customizable.
]

```typ
#note[
Highlights information that users should take into account, even when skimming.
]

#tip[
Optional information to help a user be more successful.
]

#important[
Crucial information necessary for users to succeed.
]

#warning[
Critical content demanding immediate user attention due to potential risks.
]

#caution[
Negative potential consequences of an action.
]

#admonition(
  icon: "icons/stop.svg",
  color: color.fuchsia,
  title: "Custom Title",
)[
  The icon, color and title are customizable.
]

```