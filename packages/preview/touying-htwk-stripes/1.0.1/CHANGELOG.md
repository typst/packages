# v1.0.1 (2026-06-08)

## General
- add parameter `font-scaling` to `htwk-stripes-theme` function
- update touying to `v0.7.4`

### Slides
- **Focusslide**
    - centered content
    - no navigation or other information besides content shown

## Fixes
- not providing a sources slide would result in broken indexes in the navigation
- `subtitle` defaults to `none` instead of `[]`

# v1.0.0 (2026-03-08)

## General
- initial release

### Slides
- **Title Slide**
    - auto-generated based on the information passed into `htwk-stripes-theme`
- **Outline Slide**
    - wraps typst's `outline` function to only show top level headings
    - not present in the slide navigation
- **Sources Slide**
    - not present in the slide navigation

## Fixes
/
