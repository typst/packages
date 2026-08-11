# Testing


Links

  * [Devcontainer](https://containers.dev/)
  * [Devcontainer in VSCode (Visual Studio Code)](https://code.visualstudio.com/docs/devcontainers/containers)
  * [GitHub Codespaces](https://github.com/features/codespaces)

Folders

* `tests`: Folder with tests
* `bin/autotest.sh`: Script which runs all tests
* Tytanic: https://github.com/typst-community/tytanic

## Running the tests manually

```bash
just check
```

### Test environment: Devcontainer in VSCode

Clone this repo and open VSCode

`glossy.code-workspace`

VSCode will ask you if you would like to start the devcontainer: Yes

Wait for a few minutes until you see `*** Container build successfully ***`

Open a terminal and type

```bash
$ typst --version
typst <installed version>
$ tt --version
tytanic <installed version>
$ tt list
$ tt run --no-fail-fast
```

### Test environment: Devcontainer in a GitHub Codespace

Browser: Open https://github.com/swaits-typst-packages/glossy
Click `Code` -> `Codespaces` -> `Create codespace on` and select the branch you want to test.

Wait for a few minutes until you see `*** Container build successfully ***`

Open a terminal and type as above.

## Testrunner and CI pipelines

* Testrunner: https://github.com/typst-community/tytanic
* Repo using the testrunner in a ci pipeline: https://github.com/janekfleper/typst-fancy-units/blob/main/.github/workflows/ci.yaml
