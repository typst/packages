# Team Bath Racing Electric Documentation Template

A highly customizable, locally deployed Typst template designed for the TBRe documents or documentation. 

This template features automatic list-of-abbreviations generation and an automated changelog powered by `git-cliff` [1].

Use [git-cliff](https://git-cliff.org/) to generate changelog.typ from your git commit history following the Conventional Commits specification TYPE(CHAPTER): COMMIT MESSAGE

## Prerequisites
To compile this document locally, you will need:
1. **Typst CLI**: For compiling the document into a PDF.
2. **git-cliff**: A command-line tool that generates changelogs from your Git repository history using conventional commits [2, 3].

## Initialising the Template

To use this template after installation simply run the following commands.
```sh
typst init '@preview/documenting-tbre:0.1.0' name-of-your-project
cd name-of-your-project
typst watch main.typ
```

### Git Recommendation

In order to reduce repository bloat enable git LFS to track the image files used in figures.
```sh
git lfs install
git lfs track "*.png" "*.jpg" "*.jpeg" "*.svg"
git add .gitattributes
git commit -m "Configure Git LFS to track image files"
```

## Installing as a Local Package from a Remote Repository
To use this template across multiple projects without copying the source files every time, you can install it into Typst's local package directory directly from the remote repository.

**Step 1: Locate your Typst local package directory**
Typst looks for local packages in a specific data directory depending on your operating system:
* **Windows:** `%APPDATA%\typst\packages\local\`
* **macOS:** `~/Library/Application Support/typst/packages/local/`
* **Linux:** `~/.local/share/typst/packages/local/`

**Step 2: Clone the repository**
Create a folder structure matching the package name and version defined in the `typst.toml` file (`documenting-tbre/0.1.0`), and clone the remote repository into it. 

For example, on Linux/macOS:
```bash
mkdir -p ~/.local/share/typst/packages/local/documenting-tbre/0.1.0
git clone <YOUR_REMOTE_REPO_URL> ~/.local/share/typst/packages/local/documenting-tbre/0.1.0
typst init '@local/documenting-tbre:0.1.0' name-of-your-project
```
## Project Structure
Ensure your project directory looks like this:
```text
.
├── LICENSE          # License file
├── README.md        # Project documentation
├── typst.toml       # The Typst package manifest
├── src/
│   └── lib.typ      # Template formatting, preamble, and helper functions
└── template/
	├── changelog.typ # (Auto-generated) Changelog table created by git-cliff
	├── cliff.toml   # git-cliff configuration and Typst table template
	├── images/      # Image assets used by the template
	├── main.typ     # Main template/report content
	└── refs.bib     # Bibliography entries
```