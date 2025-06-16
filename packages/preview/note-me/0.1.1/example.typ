// Import from @preview namespace is suggested
// #import "@preview/note-me:0.1.1": *

// Import from @local namespace is only for debugging purpose
#import "@local/note-me:0.1.1": *

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
  background-color: color.silver,
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