# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0]

### Bug Fixes

- Fixed inconsistent color rendering across pages: colors are now applied coherently page by page throughout the entire document.

### Breaking Changes

#### Renamed: `theme` → `palette`

The `theme` concept has been renamed to `palette` everywhere for clarity.

- The `theme` parameter of the `cookbook` function is now `palette`.
- The `themes.*` namespace is now `palette.*`.
- The `set-theme` function has been replaced — see below.

Before:
```typ
#show: cookbook.with(
  title: "My Cookbook",
  theme: themes.blue
)
```

After:
```typ
#show: cookbook.with(
  title: "My Cookbook",
  palette: palette.blue
)
```

---

#### Renamed: `indexes` → `custom-indexes`

The `indexes` parameter of the `cookbook` function has been renamed to `custom-indexes` for consistency with the other `custom-*` parameters.

Before:
```typ
#show: cookbook.with(
  title: "My Cookbook",
  indexes: indexes
)
```

After:
```typ
#show: cookbook.with(
  title: "My Cookbook",
  custom-indexes: indexes
)
```

---

#### Renamed: `author` → `authors` in `recipe`

The `author` property of the `recipe` function has been renamed to `authors` and now supports multiple authors.

Before:
```typ
#recipe(
  [Banana Jam],
  author: [GrandMa]
)
```

After (single author):
```typ
#recipe(
  [Banana Jam],
  authors: [GrandMa]
)
```

After (multiple authors):
```typ
#recipe(
  [Banana Jam],
  authors: ([GrandMa], [GrandPa])
)
```

---

#### Replaced: `set-theme` → `chapter`, `next-palette`, `set-all-palettes`

The `set-theme` function has been replaced by three more specialized functions that give you finer control over color changes:

- **`chapter`**: creates a chapter separator page and sets the palette for that chapter.
- **`set-all-palettes`**: lets you manually define all palette change points at once.

Before:
```typ
#set-theme(themes.green)
```

After:
```typ
#chapter(palette: palette.green)[Main]
// or
#set-all-palettes(pages-palettes)
```

---

### New Features

#### New palettes

Six new palettes have been added:

- `amber`
- `coral`
- `forest`
- `lagoon`
- `rose`
- `slate` (new default, replaces `grey`)
- `sunset`

The default palette is now **`slate`** (previously `grey`).

---

#### `recipe`: new `change-palette` property

You can now change the palette directly from within a recipe using the `change-palette` property.

---

#### `cookbook`: new `chapter-start-right` behavior

The `chapter` function now integrates with `chapter-start-right` to ensure chapter separator pages always land on the correct side.
 
## [1.0.0]

- Initial release.