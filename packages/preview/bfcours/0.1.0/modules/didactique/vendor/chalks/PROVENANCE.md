# Vendored copy of chalks 0.1.1

Origin: `chalks` 0.1.1 by Jinguo Liu (GiggleLiu), MIT licence, https://github.com/GiggleLiu/chalks
(see `LICENSE`, `THIRD_PARTY-NOTICES.md` and `licenses/`, kept unchanged). The `images/` folder,
the README and the manifest of the original package are not included.

## Local patch

`src/engine.typ`, function `render-paths`: the cubic Bezier segments of each outline are merged in groups
of `n` (tangents doubled at the ends). `n` is held by the state `chalks-decimation`; bfcours sets it to 2
by default (1 draws the exact outline). Users can change it with `bf-craie-allegement(n)`.

## Why

The engine samples outlines at a fixed resolution, up to 2048 cubics for one frame, and every cubic
weighs on the PDF. One chalk frame of a "Démonstration" box costs about 105 KB in the PDF; with the merge
it costs 54 KB (n = 2) or 37 KB (n = 3), with a very slightly smoother stroke.

## Plan

Go back to `@preview/chalks` as soon as upstream offers an equivalent option (a request has been opened on
https://github.com/GiggleLiu/chalks), then delete this folder.
