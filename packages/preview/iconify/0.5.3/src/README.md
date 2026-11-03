# JSON format

JSON files like `lucide.json`, `mdi.json`, etc. Each file contains the icons of a specific collection.

Useful part of the format.

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
