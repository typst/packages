# Play DOOM

Open `main.typ` in live preview and type commands at the bottom of the document.
Freedoom: Phase 1 is included, so no extra game files are needed.

`w/s` moves, `a/d` strafes, `j/l` turns, `f` fires, and `e` opens doors.
`x` waits, `m` shows the map, and `r` restarts. Uppercase `WASD` runs.
Delete commands to rewind; save the document to keep your playthrough.
Nothing advances while you stop typing. Put notes in `// comments`.

To change controls, uncomment the `actions` line in `main.typ`:

```typst
actions: (fire: ("v",), use: ("u",)),
```

Other controls keep their defaults. Add aliases with `forward: ("w", "↑")`,
or disable an action with `fire: ()`. Each key can belong to only one action.
Clear old input when changing bindings.

Use `p` for the menu, `i/k` to select, `h/o` to adjust, `c` to confirm,
`b` to go back, and `y/n` to answer prompts.

To use your own DOOM IWAD, copy it into this project and uncomment the `wad` line.
The starter files in this directory are licensed under MIT-0; see `LICENSE`.
