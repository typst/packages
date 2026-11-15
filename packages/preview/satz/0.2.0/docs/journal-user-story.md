# Starting a journal entry

## User story

As a researcher, I want to start a journal entry quickly in my preferred editor,
so I can record work, decisions and questions without managing files manually.
The journal can also be used for teaching, personal notes or any other purpose.

## Everyday experience

The user starts `journal` from anywhere, or opens a shortcut for the same action.
With one registered journal, it is selected automatically. With several, a short
chooser shows their names, with the most recently used highlighted. The selected
journal is visible before an entry is created.

The user enters a title, optionally chooses meeting, work session or blank notes,
and adds keywords if useful. The entry opens in their preferred editor. Dates,
filenames, folders and the main document's include list are handled for them.

## First use and ownership

On first use, the launcher offers to create a journal or connect an existing
one. Creating a journal copies the clean starter into a chosen folder, with a
cover, editable settings, index and first example entry. It never copies another
person's research notes. Journals in different folders stay independent.

The cover, colors, paper and entry structure are customizable. The settings
contain deliberate overrides, so Satz can supply updated defaults. Journal
content remains ordinary local Typst files, usable without the launcher and
suitable for normal backup, version control and sharing.

## Acceptance criteria

- Starting an entry never requires navigating to a project folder first.
- Creating a second journal never overwrites the first journal or its settings.
- The selected journal is clear before the file is created.
- Meeting and session scaffolds are useful, and blank notes remain available.
- New entries get a date, a safe filename and a main-document include automatically.
- The editor opens the new entry in the context of the whole journal project.
- Existing files are never overwritten by a new-entry action.
- Basic use requires no Python, Node or Go installation.
- Users can keep writing if the launcher is removed.

## Implementation boundary

The initial standalone helper supports creating journals, remembering an active
journal, explicit project paths and entry scaffolding. It can run from anywhere
using that remembered project. A named multi-journal chooser and graphical
shortcut/onboarding are the product target above; they must not be described as
implemented until those interactions are built and tested.

The first sharing artifact is a plain starter ZIP. Public executable downloads
need clear versioned releases from the project's repository; unsigned development
builds are review artifacts rather than a finished public installer.

## One-file-first Satz onboarding

The agreed direction is a simple package API and one editable Typst file first.
A CLI should scaffold a working example; a beginner should not have to create
separate config, setup, cover and main files. Larger projects may split their
content and settings later using ordinary Typst imports.

The proposed general entry point is `satz new journal`, `satz new report`,
`satz new letter`, and `satz new proposal`. A `journal` shortcut can provide the
focused daily workflow: launch/choose a journal, start a new entry, or create
another journal. These names are design proposals, not implemented CLI commands.

The current shareable starter is the modular baseline. Simplifying it to the
one-file path comes before adding a comprehensive multi-template CLI. The goal
is to remove setup work and teach only a few writing conventions initially:
headings, lists, emphasis and images. Advanced formatting stays in Satz.
