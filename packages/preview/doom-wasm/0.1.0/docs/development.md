# Development

Run the commands below from the repository root.

## Engine interface

```typst
#import "lib.typ": new-game, advance, info, framebuffer
#let first = new-game(read("assets/freedoom1.wad", encoding: none), tics: 1)
#let second = advance(first, "wwff")
#let state = info(second)
#let pixels = framebuffer(second)
```

`new-game` starts the engine. `advance` applies commands and returns a new game
state, leaving the old one unchanged. `info` returns a dictionary with the
player's position, health, ammo, and other state. `framebuffer` returns RGB bytes.

Both `new-game` and `advance` use `plugin.transition`. Use these functions when
changing engine state so Typst can track and cache the resulting snapshots.
An `advance` call can take up to 4,096 command bytes.

`play` handles a whole input history. It splits the commands into blocks of 16,
which lets Typst reuse earlier blocks when you append input in live preview.
A new compiler process still has to replay the history. Cached states can also
be discarded when memory is needed.

`game` is the show rule used by the template, and `doom` is an alias for it.
The older `engine/doom.typ` import still defaults to a local `assets/doom1.wad`.
The package entry point, `lib.typ`, defaults to Freedoom.

## How it runs

The adapter in `engine/native/` supplies input, a virtual clock, and file access
for the WAD and save slots. DoomGeneric handles the game logic and rendering.
There is no sound, multiplayer, or screen-wipe animation. The game advances when
you type a command.

WAD lumps are read directly from the supplied bytes. This avoids making another
copy of each resource in Doom's heap. The original BSP renderer is still used.
It draws nearer geometry first and skips areas that are already hidden.

Rendering runs on every tic because the fuzz effect and HUD keep state between
frames. Only the frame requested by Typst is converted to RGB. Typst displays
those bytes with its `rgb8` image format.

`engine/native/draw.c` has versions of the column and span loops that keep texture
and lighting pointers in local variables. They keep the original arithmetic and
lookup order. Low-detail, fuzz, and translated drawing use the original code.

Save slots live in memory and are rebuilt from the input history. The menu's
Save option doesn't write a file to your computer. To do that, use the export
commands below.

## Optional save export

Saving the document keeps your input history. If it gets too long, you can export
a native game save and continue with an empty history:

```sh
mkdir -p build
typst eval --input export-save=true --in main.typ 'query(<doom-save>).first().value' > save.json
typst compile --input save=save.json --input actions= main.typ build/loaded.pdf
typst compile --input save=save.json --input actions=wwff main.typ build/continued.pdf
```

Export while you're in a level. The JSON file contains the bytes of a DOOM
`.dsg` save. In the supplied `main.typ`, the save path is relative to that file.
Clear the old commands before continuing, or they will be replayed after loading.

Native saves don't preserve every engine detail, including the random-number
state. Keep the input history if you need an exact replay.

For scripts, use `save-game(game)`, `saved-bytes(game)`, and
`load-game(game, bytes)`.

## Building the engine

The repository includes `engine/doom.wasm`, so you only need a C toolchain if
you're changing the engine. Install the WASI SDK, then run:

```sh
WASI_SDK_PATH=/path/to/wasi-sdk python3 scripts/build_engine.py
```

The script also looks for the SDK at `build/wasi-sdk-34.0-arm64-macos`. It builds
DoomGeneric with the adapter and checks that the WASM imports only Typst's two
plugin protocol functions.

If `ccache` is installed, the build uses it and stores its cache in `build/ccache`.
Use `--no-ccache` to turn it off. `--jobs N` sets the number of compiler workers;
the default is the CPU count.

The build runs `wasm-opt -O3` when Binaryen is available. It checks `--wasm-opt
PATH`, `WASM_OPT`, `PATH`, and then `build/binaryen-version_131/bin/wasm-opt`.
Binaryen 131 was used for testing. Use `--no-wasm-opt` to skip it.

Other build options:

| Flag | What it does |
| --- | --- |
| `--output PATH` | Writes a separate WASM file for testing |
| `--lto` | Enables link-time optimization |
| `--gc-sections` | Enables section-based dead-code removal |
| `--initial-memory BYTES` | Sets initial memory; `0` lets the linker choose |

LTO and section GC are off by default. With LTO, the build uses the SDK's ordinary
libc archive because SDK 34's LTO libc adds a `random_get` import that the plugin
can't use.

Memory grows as needed, up to 128 MiB. Doom's zone allocator gets 16 MiB.
Each build has its own temporary directory. The output file is replaced only
after linking, optimization, and import checks succeed. If two builds use the
same output path, the last successful build wins.

The vendored DoomGeneric revision is
`dcb7a8dbc7a16ce3dda29382ac9aae9d77d21284`. Its Makefile supplies the source list;
the adapter replaces the Xlib host. The build has a known upstream warning about
`abs` on an unsigned value in `r_segs.c`.

## Tests

```sh
make test
make test-package
```

These need Typst, Python, and a native C compiler. `make test` runs checks in
parallel; use `make test TEST_JOBS=1` to run them one at a time.

The default tests cover all 36 Freedoom level starts, movement, firing, menus,
keybindings, save/load, and replay across different chunk sizes. They also check
the memory filesystem, build script, and WASM imports.

If `assets/doom1.wad` is present, `make test` also runs the original DOOM tests.
These include a 2,314-command E1M1 playthrough that reaches the exit with 63 health
and two kills, then continues into E1M2. The WAD is not included in the repository.
Neither test set covers a full campaign.

`make test-package` builds the package, creates a project with `typst init`, and
tests gameplay, custom controls, CLI input, and save files. It also compiles the
web zip after extracting it into a separate directory.

To compare an engine change with the previous build, keep a copy before rebuilding:

```sh
mkdir -p build
cp engine/doom.wasm build/previous.wasm
# Make your changes and rebuild, then:
typst compile --root . --input reference=/build/previous.wasm tests/native-equivalence.typ build/equivalence.pdf
```

This comparison needs the local shareware `assets/doom1.wad`. It checks game state
and every pixel at 237 points across nine maps and the E1M1-to-E1M2 replay.
Add `--input candidate=/build/candidate.wasm` to test a separate build without
replacing `engine/doom.wasm`. The leading `/` means the Typst project root.

## Benchmarks

```sh
python3 scripts/benchmark.py --output build/benchmark.json
```

The benchmark starts with 700 commands and appends eight more in `typst watch`.
It records compile times, image and engine hashes, and peak memory use and CPU
time on macOS/Linux. File notifications need to work for the edit tests to finish.

It uses Freedoom by default. Use `--wad assets/doom1.wad` for the original DOOM
shareware workload. To try another engine or chunk size:

```sh
python3 scripts/benchmark.py --engine build/candidate.wasm --chunk-size 8 --commands 2800 --edits 32 --output build/candidate.json
```

The results below came from the shareware WAD on one machine with Typst 0.15.1.
They measure CLI PNG output; editor and web-app timings may differ.

With 700 commands, 32 edits, 16-command chunks, and the former 32 MiB initial
memory setting:

| Build | WASM size | First compile | Mean edit |
| --- | ---: | ---: | ---: |
| LLVM `-O2` | 447 KB | 2.37 s | 0.209 s |
| Section GC | 447 KB | 2.30 s | 0.217 s |
| Binaryen `-O3` | 399 KB | 2.21 s | 0.189 s |
| LTO | 521 KB | 2.20 s | 0.196 s |
| LTO + section GC + Binaryen | 462 KB | 2.25 s | 0.208 s |

The images matched across builds. Binaryen alone gave a smaller file and good
edit times, so that's the default when it's installed.

After trimming closed save buffers and lowering initial memory, that build was
399,801 bytes. It took 2.29 s for the first compile and 0.191 s per edit. All 33
images matched the earlier build, as did the 237-point engine comparison.

Changing the chunk size with Binaryen gave:

| Commands per chunk | First compile | Mean edit | Slowest edit |
| ---: | ---: | ---: | ---: |
| 4 | 2.59 s | 0.156 s | 0.168 s |
| 8 | 2.42 s | 0.162 s | 0.174 s |
| 16 | 2.29 s | 0.177 s | 0.209 s |
| 32 | 2.26 s | 0.207 s | 0.266 s |

Smaller chunks made edits a little faster but used more memory. With 2,800
commands, chunks of 4 or 8 used roughly 10–12 GiB, compared with 6.35 GiB for
chunks of 16 under the old memory setting. Lowering initial memory brought that
16-command run down to 4.38 GiB in a repeat test. Memory use varies with cache
collection, and long histories can still get expensive. The default stays at 16.

Shorter engine warmups changed the initial frame, so the warmup stays at 17 tics.
Larger 24/32 MiB Doom heaps used more memory without much improvement in startup
time. Rendering still runs every tic to keep the fuzz effect and HUD consistent.

## Game options

| Option | Default | What it does |
| --- | --- | --- |
| `wad` | Freedoom Phase 1 | Use another IWAD's bytes; `none` shows setup instructions |
| `skill` | `3` | Difficulty, `1`–`5` |
| `episode` | `1` | Episode, `1`–`4` |
| `map` | `1` | Map number; it must exist in the IWAD |
| `tics` | `4` | Game tics per command, `1`–`35` |
| `actions` | `(:)` | Change selected keybindings |
| `help` | `true` | Show controls below the game |
| `chunk-size` | `16` | Commands per cached transition |
| `save` | `none` | Native DOOM save bytes to load before the commands |

To use your own DOOM II IWAD, pass `wad: read("doom2.wad", encoding: none)`.
The adapter recognizes its map format, but a full DOOM II playthrough hasn't
been tested here.

Available action names:

```text
forward, backward, strafe-left, strafe-right
run-forward, run-backward, run-left, run-right
turn-left, turn-right, fire, use, forward-fire, backward-fire
weapon-1, weapon-2, weapon-3, weapon-4, weapon-5, weapon-6, weapon-7
automap, wait, restart, menu
menu-up, menu-down, menu-left, menu-right, confirm, back, yes, no
```

Import `default-actions` to see the default keys. If a key is also Typst markup,
put the commands in a raw text block. Clear the old commands when changing
bindings, since they'll be read using the new controls.
