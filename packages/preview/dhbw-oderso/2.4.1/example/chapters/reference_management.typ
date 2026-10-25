= Reference Management (Recommended: JabRef + BibTeX)

The recommended best practice for managing references in this project is to use the graphical citation manager *JabRef* to maintain a *BibTeX (`.bib`) file*.

== Installing JabRef (macOS via Homebrew)

If you are on macOS, install JabRef using Homebrew:

```bash
brew install --cask jabref
```

Once installed, launch JabRef from your Applications folder or Spotlight.

== Opening the Project BibTeX File

1. Open *JabRef*
2. Go to *File → Open library*
3. Open the file:

```text
path_to_your_thesis/template/refs.bib
```

This file serves as the central reference database for the project.


== Adding References in JabRef

=== Option A (Recommended): Import by DOI

This is the preferred and most reliable method.

1. In JabRef, click *Lookup → Search by DOI*
2. Paste the DOI (e.g., `10.1145/1234567.8901234`)
3. JabRef will automatically fetch the full reference
4. Review the fields and accept the entry

JabRef will automatically generate a *citation key*, which you will use in Typst.


=== Option B: Add an Entry Manually

Use this only if no DOI is available.

1. Click *Add entry*
2. Choose the entry type (e.g., `Article`, `Book`, `InProceedings`)
3. Fill in the required fields (author, title, year, etc.)
4. Ensure a unique *citation key* is set


=== Option C: Import Existing BibTeX

If you already have a BibTeX entry:

- Paste it directly into JabRef, or
- Use *File → Import into current library*


=== Using the Citation Key in Typst

Each reference in JabRef has a *citation key* (e.g., `smith2023example`).
Use this key directly in Typst:

```typst
@smith2023example
```

Typst will resolve the citation using `refs.bib`.

== Important: Save Your Changes

After adding or editing references, always save the file in JabRef:

- *File → Save* (or `Cmd + S`)

Changes are not written to `refs.bib` until the file is saved.
