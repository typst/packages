# Academic Template

A modular [Typst](https://typst.app/) template for academic papers, **preconfigured for the formatting and citation requirements of IU Internationale Hochschule**. The defaults are customizable through each paper's `config.typ`, so the template can also be adapted to other requirements. Typst turns plain-text source files into professionally typeset PDFs.

**Language:** [Deutsch](README.de.md) | **English**

> **Unofficial project.** Academic Template is independently developed and is not published, endorsed, or maintained by IU Internationale Hochschule. Always check the current rules for your course and assessment before submitting your work.

**Package version:** `1.0.0`
**Distribution:** Typst Universe (`@preview`); local installation from source is also supported.

## What the template provides

- Configurable title page, page layout, headings, and page numbering
- German (`de`) and US English (`en`) labels and document settings
- Automatically generated table of contents, figure and table lists, and abbreviation list
- Reusable figures and tables with captions, notes, and source information
- Appendices with configurable figure and table numbering
- Citations and bibliography with IU-oriented and APA styles
- Separate paper projects that share one installed template library

**Recommended bibliography setup:** **Citrus + CSL-JSON + IU style**. Other engine/file combinations are available, but their metadata and rendered citations require independent review. See the [Bibliography Guides](#documentation) for details.

## Requirements

- **For local work:** Typst CLI 0.15.0 or newer and a text editor of your choice (for example, Visual Studio Code with Tinymist)
- **For online work:** A browser and a Typst web app account; no local installation is required

The default font setting prefers **Arial** and uses **Liberation Sans** if Arial is unavailable (for example, in the web app). You can specify a different font in your paper's `config.typ`. A substitute font may change the layout, so check the finished PDF against your institution's requirements.

### Install Typst

Install the Typst command-line compiler **before** initializing a paper. This is separate from installing the Academic Template.

**Windows** (PowerShell):

```powershell
winget install --id Typst.Typst
```

**macOS** (Homebrew):

```bash
brew install typst
```

**Linux:** Install the `typst` package using your distribution's package manager, or download the appropriate executable from the [official Typst installation page](https://typst.app/open-source/).

Verify the installation in a new terminal:

```bash
typst --version
```

For additional installation methods, see the [official Typst installation instructions](https://typst.app/open-source/).

## Quick start with Typst Universe (recommended)

**In the Typst web app (without installation):** Open the [Typst web app](https://typst.app/), sign in, select **Start from template**, search for **iu-academic-template**, and create a project. Edit the project in your browser, view the live preview, and export the finished PDF.

**With the local Typst CLI:** Once Typst is installed, create a paper using the published template:

```bash
typst init @preview/iu-academic-template:1.0.0 my-paper
cd my-paper
```

Typst downloads the published package automatically. Open the new project folder in your editor. In either workflow:

1. Enter your paper details and customize the formatting in `config.typ`.
2. Write your chapters and main content in `content.typ`.
3. Add or update sources in `references.json` (or use `references.bib` or `references.yaml` with the appropriate configuration).
4. Optionally, define abbreviations in `abbreviations.typ` and use them in your text.
5. Optionally, add supplementary material in `appendices.typ` and store images, diagrams, or other files used in your paper in `assets/`.

**For local projects**, generate the PDF from the project folder:

```bash
typst compile main.typ
```

This creates `main.pdf`. Always compile `main.typ`, not the other `.typ` files, as it is the entry point that assembles your document. To rebuild the PDF automatically whenever a source file changes, run `typst watch main.typ` instead. **In the web app**, the preview updates as you edit, and you can export the PDF directly.

**Using Visual Studio Code:** Open the project folder via **File → Open Folder** and install the **Tinymist** extension. You can then edit your project's `.typ` files directly in VS Code, including `config.typ`, `content.typ`, `abbreviations.typ`, and `appendices.typ`.
To export the complete document as a PDF, open `main.typ` and make sure it is the active file in the editor. Then open the Command Palette with `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (macOS); alternatively, press `Ctrl+P` or `Cmd+P` and type `>`. Search for Typst commands such as `Typst: Export the Opened File as PDF` or `Typst: Preview opened File in Browser`(available commands depend on the installed extension).
You can also use the integrated terminal (**Terminal → New Terminal**) to run `typst compile main.typ` or `typst watch main.typ` and open the generated PDF in a viewer.

**Using Zotero (optional):** Manage your sources in Zotero and export them as **CSL JSON** (`references.json`, recommended) or **BibLaTeX** (`references.bib`). Zotero also supports BibTeX export, which is distinct from BibLaTeX; **Hayagriva YAML** requires conversion. Check the exported metadata and citation keys. See the [Bibliography Guide](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/docs/bibliography-guide.pdf) for details.

The [Starter README](starter/README.md) provides a quick reference for day-to-day work; see the User Guides for detailed instructions.


For a complete example, explore the [`demo/`](https://github.com/BeaverBytes/academic-template/tree/v1.0.0/demo/) folder. It contains a sample academic paper that demonstrates the template's features and shows what a finished document can look like. See the [demo README](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/demo/README.md) for details.

## Local installation from source (optional)

For template development or a local installation, first obtain the source repository:

- **Clone with Git:** Clone the source repository from GitHub:

  ```bash
  git clone https://github.com/BeaverBytes/academic-template.git
  cd academic-template
  ```

- **Download a ZIP:** Select **Code → Download ZIP** on GitHub, extract the archive and open the extracted folder containing `typst.toml` in your terminal.

Then run the installer **from that folder**:

**Linux / macOS** (Bash):

```bash
chmod +x install.sh
./install.sh
```

**Windows** (PowerShell 5.1 or 7):

```powershell
.\install.ps1
```

If PowerShell blocks the script, inspect it first. For a trusted script, you can permit execution for the current session only:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install.ps1
```

**After the local installation has completed**, initialize a new paper (from the directory where you want the paper to be created):

```bash
typst init @local/iu-academic-template:1.0.0 my-paper-local
cd my-paper-local
typst compile main.typ
```

The installer prepares the `@local` import in the **installed starter copy**. It does not change the repository's starter or the `project.typ` files of existing papers. No manual import edit is required for newly initialized local projects. Administrator rights are normally not required. Edit and compile the local project using the same steps as in the [quick start](#quick-start-with-typst-universe-recommended).

## How projects are organized

Each new paper receives its own configuration, text, bibliography, abbreviations, and optional appendices. Its `project.typ` connects it to the shared installed library. You normally do not need to edit `main.typ` or `project.typ`.

| In a generated paper | Purpose |
| --- | --- |
| `config.typ` | Title page, language, formatting, lists, and bibliography settings |
| `content.typ` | Main chapters and text |
| `references.json` | Default CSL-JSON bibliography |
| `references.bib`, `references.yaml` | Optional alternative bibliography files |
| `abbreviations.typ`, `appendices.typ` | Optional abbreviations and appendix content |
| `main.typ`, `project.typ` | Document assembly and connection to the installed package |

The public source repository has these main components:

```text
academic-template/
├── typst.toml       # Package manifest
├── template/        # Shared template implementation
├── vendor/          # Bundled Citrus dependency
├── starter/         # Files copied by typst init
├── demo/            # Compact example paper
├── docs/            # User guides and bibliography guides
├── install.sh       # Linux/macOS installer
└── install.ps1      # Windows installer
```

## Documentation

| Document | Purpose |
| --- | --- |
| [Starter README (English)](starter/README.md) / [Deutsch](starter/README.de.md) | Quick reference inside a new paper |
| [User Guide (English)](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/docs/user-guide.pdf) / [Deutsch](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/docs/user-guide.de.pdf) | Detailed instructions for writing and using template functions |
| [Bibliography Guide (English)](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/docs/bibliography-guide.pdf) / [Deutsch](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/docs/bibliography-guide.de.pdf) | Entering sources, bibliography formats, citation methods, and reference-list output |
| [Demo README (English)](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/demo/README.md) / [Deutsch](https://github.com/BeaverBytes/academic-template/blob/v1.0.0/demo/README.de.md) | Scope and build instructions for the demonstration paper |

For general Typst syntax and command-line usage, see the [official Typst documentation](https://typst.app/docs/).

## Updates

Published packages are versioned: a paper keeps using the `@preview` version specified in its `project.typ` until you change that import. After upgrading, review the resulting PDF.

For local development, first update your source repository (e.g. using `git pull`, or by downloading the latest ZIP), then rerun `install.sh` or `install.ps1` to update the **locally installed version**. Only projects importing that same `@local` package version in their `project.typ` file will use the updated template code when recompiled; projects importing other versions remain unaffected. Existing project files, including `project.typ`, are **not** overwritten.

**Before submitting a paper:** Verify its formatting and citations against the currently applicable IU requirements and your course-specific instructions. The template is an aid, not a compliance guarantee.

## Licensing

The project's original code and documentation are provided under the [MIT License](LICENSE), with these exceptions:

- The starter files in [`starter/`](starter/) are licensed under [MIT No Attribution (MIT-0)](starter/LICENSE). This license is included in each generated project. The original template-library code remains MIT-licensed.
- The bundled [Citrus library](vendor/citrus/) retains its own [MIT license](vendor/citrus/LICENSE).
- The citation styles [`apa.csl`](template/styles/apa.csl) and [`iu-citrus.csl`](template/styles/iu-citrus.csl) retain their **CC BY-SA 3.0** license terms, as stated in the respective files.

Using the template to produce a paper does not, by itself, require crediting BeaverBytes in the resulting PDF. The licenses still apply if you redistribute the licensed source files.
