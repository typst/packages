# Development

## Engine interface

```typst
#import "lib.typ": new-game, advance, info, framebuffer
#let first = new-game(read("assets/freedoom1.wad", encoding: none), tics: 1)
#let second = advance(first, "wwff")
// first is unchanged; second is a derived engine snapshot.
#let state = info(second)
#let pixels = framebuffer(second)
```

`new-game` and `advance` use Typst's `plugin.transition` API. `info` returns a
small diagnostic dictionary; `framebuffer` returns RGB bytes. `play` replays
input in stable 16-command blocks so Typst can cache prefixes. A single
`advance` call accepts up to 4,096 command bytes.

During a running `typst watch` session, cached transition results can survive
recompilation: appending input reuses unchanged blocks. This is an optimization,
not durable storage; a fresh compiler process or an evicted cache must replay
the history. Smaller blocks limit how much of the unfinished block must be
replayed on each edit, at the cost of retaining more cached transition results.

The image uses Typst's raw `rgb8` format directly; no PNG encoder is needed in
WASM. Engine mutations must go through `plugin.transition`, which produces a
derived module, rather than relying on side effects between ordinary calls.

The adapter supplies a virtual clock and a memory-backed IWAD file. The original
DoomGeneric code handles simulation, fixed-point physics, BSP rendering, sprites,
monsters, weapons, HUD, menus and level progression. Rendering runs once per tic
to preserve display state independently of transition chunk boundaries.

The IWAD uses Doom's existing memory-mapped lump path: cached resources point
directly into the input bytes instead of being copied through libc streams into
the zone allocator. Typst caches the surrounding engine transitions. The native
BSP renderer already visits front geometry first and rejects occluded regions;
changing that traversal to back-to-front would undermine its visibility logic.

Only the final requested frame is expanded from Doom's indexed pixels into RGB.
Intermediate ticks still run the original renderer, including its persistent
fuzz and HUD state, but skip conversion into the unused host screen buffer.

The adapter also specializes the normal column/span pixel loops in
`engine/native/draw.c`: texture and lighting pointers are loaded once per draw
call instead of reloading globals at every pixel. The coordinate arithmetic and
lookup order are retained, with explicit unsigned 32-bit wrapping. Low-detail,
fuzz, and translated drawing paths remain the original engine implementations.

The original save/load menus work through a small in-memory filesystem, and Quit
stops the derived game snapshot. Type `r` to restart. Slots are reconstructed from
your input history on each compilation; they do not write to your computer.

This document-based port is silent, skips screen-wipe animations, and has no
multiplayer networking. It advances on typed input rather than wall-clock time.

## Optional save export

Usually, preserving the input text is enough. For a separate save file:

```sh
typst eval --input export-save=true --in main.typ 'query(<doom-save>).first().value' > save.json
typst compile --input save=save.json --input actions= main.typ build/loaded.pdf
typst compile --input save=save.json --input actions=wwff main.typ build/continued.pdf
```

The JSON contains the bytes of an original DOOM `.dsg` save. Save paths passed on
the CLI are relative to the Typst project root. Clear the old commands when
loading, then enter new commands; otherwise they will be played again. Export
is available while in a level. Native DOOM save-format limitations still apply.
This is a native game save, not a complete WASM snapshot or an exact continuation
of every engine detail (such as the random-number generator). Typst does not
rewrite the input document automatically; exporting and loading a save is an
explicit way to start a shorter input history.
The API also exposes `save-game(game)`, `saved-bytes(game)` and
`load-game(game, bytes)` for direct access to the native format.

## Rebuild

The included `engine/doom.wasm` runs without a C toolchain. To rebuild it:

```sh
WASI_SDK_PATH=/path/to/wasi-sdk python3 scripts/build_engine.py
```

The build also detects the existing local SDK at
`build/wasi-sdk-34.0-arm64-macos`. It compiles DoomGeneric plus the adapter in
`engine/native/`, and verifies that the resulting module imports only Typst's
two protocol functions. There are no WASI host capabilities at runtime.

The build uses `ccache` when present (cache stored in `build/ccache`) and defaults
its compile workers to the CPU count. Override with `--jobs N` or disable the
cache with `--no-ccache`. It uses [Binaryen](https://github.com/WebAssembly/binaryen)
`wasm-opt -O3` when found through `--wasm-opt PATH`, `WASM_OPT`, `PATH`, or the
local `build/binaryen-version_131/bin/wasm-opt`. Binaryen 131 was tested. Without
Binaryen, the ordinary LLVM build still works; `--no-wasm-opt` explicitly selects
that path. Existing bulk-memory, sign-extension and saturating-conversion
features are enabled for Binaryen validation.

`--lto` and `--gc-sections` are optional experiment flags, not defaults. LTO uses
the SDK's ordinary libc archive: SDK 34's LTO libc introduces a WASI `random_get`
import for stack-canary initialization. Import validation rejects that dependency.
`--output PATH` writes an isolated candidate instead of replacing the playable
module. Publication is atomic and happens only after optimization and import
validation succeed.

Initial WASM memory defaults to the linker's minimum and grows as needed, with
the same 128 MiB ceiling and 16 MiB Doom zone. `--initial-memory 33554432` restores
the former fixed 32 MiB initial allocation for comparisons.

Each build uses a private temporary directory and publishes the validated module
atomically. Concurrent builds can use separate `--output` paths; if they target
the same path, the last successful publication wins.

The retained DoomGeneric source came from revision
`dcb7a8dbc7a16ce3dda29382ac9aae9d77d21284`. It is built from
`vendor/doomgeneric/doomgeneric/Makefile`'s source list, replacing the Xlib host.
The compiler currently reports an existing unsigned-absolute-value warning in
`r_segs.c`; the original engine source is preserved.

## Verification

```sh
mkdir -p build
python3 scripts/wasm_imports.py --check engine/doom.wasm
typst compile --root . tests/native-engine.typ build/native-engine-tests.pdf
typst compile --root . tests/native-save.typ build/native-save-tests.pdf
typst compile --root . tests/native-walkthrough.typ build/native-walkthrough-tests.pdf
typst compile --root . tests/native-frames.typ 'build/native-frame-{p}.png'
```

`make test` runs Freedoom gameplay, keybinding, import, Python tool, and native
memory-filesystem checks. When a local `assets/doom1.wad` is present, it also runs
the original DOOM fixtures listed above. Checks run in parallel, preserving nonzero failure
statuses; use `make test TEST_JOBS=1` to run sequentially. It requires Python and
a native C compiler in addition to Typst. `make test-memory-fs` exercises trimmed-buffer
reopening, six save slots, append/read/rename, writes above 128 KiB, and overlapping
stream access. Multiple readers may coexist; writers and direct mutations fail
with `EBUSY` while a conflicting stream is open. Closed
file buffers are trimmed to their contents, while the full 512 KiB write/import
limit remains shared between the adapter and memory filesystem.

Checks cover exact tic increments, movement, shooting/ammo, independent snapshot
branches, identical results across transition chunk boundaries, ignored input,
restart, automap, original menu navigation/new game, and loading/rendering all
nine shareware maps. Save tests cover native serialization, importing into a
fresh game, slot replacement, original save/load menus, and clean quit.
Render fixtures show the starting view, movement/firing, original menu and E1M2.
The 2,314-command walkthrough reaches E1M1's exit with 63 health and two kills,
then checks the transition into E1M2. These checks do not establish a full
campaign playthrough or vanilla demo synchronization.

Benchmarks now default to the bundled Freedoom IWAD. For the original shareware
measurements below, supply `--wad assets/doom1.wad`. To measure cold compilation
and subsequent typed-input updates:

```sh
python3 scripts/benchmark.py --output build/benchmark.json
```

The default benchmark starts with 700 commands and appends eight more. It records
timings, image hashes, the engine hash, and (on macOS/Linux) watcher peak RSS and
CPU time. It stops its watcher automatically and fails on compiler errors.
Filesystem notifications must work; some sandboxes block them. These are CLI PNG
export measurements on one machine with Typst 0.15.1, not Tinymist/web-editor
latency guarantees.

Useful comparison options:

```sh
python3 scripts/benchmark.py --engine build/candidate.wasm --chunk-size 8 --commands 2800 --edits 32 --output build/candidate.json
```

An isolated code-generation sweep (700 commands, 32 edits, 16-command chunks,
former 32 MiB initial memory) gave:

| Build | WASM size | Cold render | Mean edit |
| --- | ---: | ---: | ---: |
| LLVM `-O2` baseline | 447 KB | 2.37 s | 0.209 s |
| Explicit section GC | 447 KB | 2.30 s | 0.217 s |
| Binaryen `-O3` | 399 KB | 2.21 s | 0.189 s |
| LTO | 521 KB | 2.20 s | 0.196 s |
| LTO + section GC + Binaryen | 462 KB | 2.25 s | 0.208 s |

All benchmark images matched. Binaryen alone is the selected size/speed tradeoff;
the small timing differences should not be read as universal rankings.

The build measured in that optimization round, including trimmed save buffers
and lower initial memory, was 399,801 bytes. Its short run measured 2.29 s cold and 0.191 s
per edit, versus 2.37 s and 0.209 s for the starting baseline. All 33 images
matched, in addition to the 237-checkpoint differential suite.

The same short workload with Binaryen showed the chunk-size tradeoff:

| Commands per chunk | Cold render | Mean edit | Slowest edit |
| ---: | ---: | ---: | ---: |
| 4 | 2.59 s | 0.156 s | 0.168 s |
| 8 | 2.42 s | 0.162 s | 0.174 s |
| 16 | 2.29 s | 0.177 s | 0.209 s |
| 32 | 2.26 s | 0.207 s | 0.266 s |

The default stays at 16. On 2,800 commands, smaller chunks saved only about
6–14 ms per edit but raised watcher peak RSS to roughly 10–12 GiB, versus
6.35 GiB for 16-command chunks with the former memory allocation. The retained
lower initial-memory setting reduced that 16-command peak to 4.38 GiB in a repeat
run, with cold time 8.70 → 8.66 s and mean edit time 0.201 → 0.202 s. An earlier
run peaked lower still; RSS depends on cache lifetime and collection timing.
Long histories therefore remain memory-intensive. You can explicitly set
`doom.with(chunk-size: 8)` for a different latency/memory tradeoff.

Other measured decisions: warmups of 10, 12 and 15 tics all changed the initial
pixels, so 17 remains part of the starting game state. Larger 24/32 MiB zone heaps
did not materially improve cold times and increased memory use. Per-byte input
validation was left alone; simulation/rendering dominates this workload. Rendering
still runs every tic to preserve fuzz/HUD state and chunk-independent results.

To compare a modified engine with a previous WASM build, retain that build before
rebuilding and run the optional differential suite:

```sh
# Before making engine changes:
mkdir -p build
cp engine/doom.wasm build/previous.wasm
# After rebuilding the modified engine:
typst compile --root . --input reference=/build/previous.wasm tests/native-equivalence.typ build/equivalence.pdf
```

Pass `--input candidate=/build/candidate.wasm` as well to compare two isolated
builds without replacing `engine/doom.wasm`.

It compares state reports and every pixel at 237 checkpoints across all nine
shareware maps and a sampled E1M1 playthrough through E1M2 entry. The reference
path is relative to Typst's project root when prefixed with `/`.


## Game options

| Option | Default | Meaning |
| --- | --- | --- |
| `wad` | Freedoom Phase 1 | Override with IWAD bytes; explicit `none` shows setup instructions |
| `skill` | `3` | Difficulty, `1`–`5` |
| `episode` | `1` | Episode, `1`–`4` |
| `map` | `1` | Map number; must exist in your IWAD |
| `tics` | `4` | Game tics per command, `1`–`35` |
| `actions` | `(:)` | Override selected keybindings |
| `help` | `true` | Show the controls below the game |
| `chunk-size` | `16` | Input commands per cached engine transition |
| `save` | `none` | Optional native DOOM save bytes to load before input |

Use `read("doom2.wad", encoding: none)` for your own DOOM II IWAD. The adapter
recognizes episodic and commercial maps. All 36 Freedoom level starts are tested;
a separate original-DOOM shareware test reaches E1M2. Neither is a full campaign test. The game is silent and has no multiplayer.


`game` is the template's show rule; `doom` is an alias. `play`, `new-game`,
`advance`, `info`, `framebuffer`, `save-game`, `saved-bytes`, and `load-game` are
also exported for scripting. The older repository import `engine/doom.typ`
continues to use the local shareware WAD by default.


Available action names:

```text
forward, backward, strafe-left, strafe-right
run-forward, run-backward, run-left, run-right
turn-left, turn-right, fire, use, forward-fire, backward-fire
weapon-1, weapon-2, weapon-3, weapon-4, weapon-5, weapon-6, weapon-7
automap, wait, restart, menu
menu-up, menu-down, menu-left, menu-right, confirm, back, yes, no
```

Import `default-actions` to inspect the complete default binding dictionary.
For keys that Typst treats as markup, put the input history in a raw text block.
Changing bindings reinterprets the whole input history; clear it to start fresh.

