*Scriptie* is a small Typst template to create standard format movie scripts.
It has title pages, scene loglines, action, dialogue, parentheticals, transitions and more.

In addition, Scriptie optionally features a hackish abuse of Typst's syntax for a very efficient screenwriting experience.

```typst
#import "@preview/scriptie:0.1.0":*
#show qscript

== INT. TYPST UNIVERSE - RIGHT NOW.

A curious Typst user is checking out the Scriptie template.

/ USER: (amazed) Wow! This is really great!

The user writes the best screenplay the world has ever seen.

/ PRODUCER: Ahh... but I don't want to produce good films.

/ USER (V.O.): Well, at least it was a joy to write.
  
- THE END.
```

Roadmap:
- [x] Refactor all formatting into nice, non-hackish commands
  - [x] Dialogue
  - [x] Bring all configurable formatting into show command
- [x] Stabilise hackish version and use the nice commands
- [ ] Add options for styling
  - [ ] Which elements should be bolded
  - [ ] Which elements should be UPPER CASE
  - [x] Which elements should be numbered
  - [x] Customise margins & other geometry
- [ ] Implement side-by-side dialog
- [x] Implement
  - ```
    TEXT SIGNS
    IN SCRIPT
    ```
- [x] Implement raw pages with just typewriter input
- [x] Add translations
  - places
    - Contd
    - == Part N: XXX ==
    - titlepage by
    - titlepage date?
    - titlepage "Unnamed screenplay"
    - titlepage keywords?
  - [x] English
  - [x] Finnish
- [ ] Write documentation for all functionality
- [x] Write examples you are allowed to share
- [x] Write packaging TOML
