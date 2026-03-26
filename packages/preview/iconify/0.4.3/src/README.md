# src

The [bun](https://bun.sh/) package manager is used to install all the icon collections ([`@iconify/json`](https://www.npmjs.com/package/@iconify/json)).

We then bundle these collections with the source code, and read the json files when an icon is requested.

More precisely:

- entrypoint: `your_doc.typ`

```typ
#import "@preview/iconify:0.4.3": icon


This is a home icon from the lucide collection: #image(icon("lucide:home", color: blue), size: 24pt)
```

- package entrypoint: `lib.typ`
  - Matches the icon collection: `lucide:home` -> collection: `lucide`, icon name: `home`
  - Checks if a corresponding `lucide.json` file exists.
  - Checks if the file has already been read and the json is already parsed (we don't want to read and parse the same file multiple times). If not, reads the file, parses the json, and stores it in a map for future use.
  - Checks if the requested icon name exists in the collection. If it does, get the svg path data. If it doesn't, returns an error.
  - replaces `currentColor` with the specified color, if any.
  - returns the svg string.

- json files: `lucide.json`, `mdi.json`, etc. Each file contains the icons of a specific collection. Useful part of the format.

```json
{
  "icons": {
    "home": {
      "body": "<path d=\"M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z\"/>",
      // optional width, height, left, top, rotation or hflip and vflip properties
    },
    ...
  },
  "aliases": {
    "house": {
      "parent": "home",
      // optional width, height, left, top, rotation or hflip and vflip properties overriding the parent icon
    },
    ...
  },
  // Optional default width and height
  "width": 24,
  "height": 24
}
```
