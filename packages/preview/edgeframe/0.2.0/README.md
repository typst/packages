# edgeframe (v0.2.0)

Custom margins and other components for page setup or layout.

## Usage

```typ
#include "@preview/edgeframe:0.2.0": *
```

```typ
#show: ef-document.with(
  header: ("Head L", "Head C", "Head R"),
  footer: ("Foot L", "Foot C", "Foot R"),
  page-count: true,
  header-alignment: center, // ignored when there are three heading positions
)
```
