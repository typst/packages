<h1 align="center">
  <img src='https://github.com/mintyfrankie/mintyfrankie/assets/77310871/64861d2d-971c-47cd-a5e8-5ad8659f2c2b'>
  <br><br>
  Brilliant CV
</h1>

<br>

> If my work helps you drift through tedious job seeking journey, don't hesitate to think about [buying me a Coke Zero](https://github.com/sponsors/yunanwg)... or a lot of them! 🥤



**Brilliant CV** is a [**Typst**](https://github.com/typst/typst) template for making **Résume**, **CV** or **Cover Letter** inspired by the famous LaTeX CV template [**Awesome-CV**](https://github.com/posquit0/Awesome-CV).

## Features

**1. Separation of style and content**

> Version control your CV entries in the `modules` folder, without touching the styling and typesetting of your CV / Cover Letter _(hey, I am not talking about **Macrohard Word**, you know)_

**2. Quick twitches on the visual**

> Add company logos, put your shiny company name or your coolest title at the first line globally or per-document needs

**3. Multilingual support**

> Centrally store your multilingual CVs (English + French + German + Chinese + Japanese if you are superb) and change output language in a blink

***(NEW)* 4. AI Prompt and Keywords Injection**

> Fight against the abuse of ATS system or GenAI screening by injecting invisible AI prompt or keyword list automatically.

## Preview

|                                                    CV                                                    |                                                    Cover Letter                                                    |
| :------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------: |
| ![CV](https://github.com/mintyfrankie/mintyfrankie/assets/77310871/94f5fb5c-03d0-4912-b6d6-11ee7d27a9a3) | ![Cover Letter](https://github.com/mintyfrankie/brilliant-CV/assets/77310871/b4e74cdd-6b8d-4414-b52f-13cd6ba94315) |

|                                       CV (_French, red, no photo_)                                       |                                            Cover Letter (_French, red_)                                            |
| :------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------: |
| ![CV](https://github.com/mintyfrankie/brilliant-CV/assets/77310871/fed7b66c-728e-4213-aa58-aa26db3b1362) | ![Cover Letter](https://github.com/mintyfrankie/brilliant-CV/assets/77310871/65ca65b0-c0e1-4fe8-b797-8a5e0bea4b1c) |

|                                       CV (_Chinese, green_)                                       |                                            Cover Letter (_Chinese, green_)                                            |
| :------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------: |
| ![CV](https://github.com/mintyfrankie/brilliant-CV/assets/77310871/cb9c16f5-8ad7-4256-92fe-089c108d07f5) | ![Letter](https://github.com/mintyfrankie/brilliant-CV/assets/77310871/a5a97be2-87e2-43fe-b605-f862a0d600d7)|


## Usage

> If you are using Typst online editor, you don't have to follow local development steps.

### 1. Install Fonts

In order to make Typst render correctly, you will have to install the required fonts [**Roboto**](https://fonts.google.com/specimen/Roboto), [**Source Sans Pro**](https://fonts.google.com/specimen/Source+Sans+3) (or **Source Sans 3**) as well as [Fontawesome 6](https://fontawesome.com/download) in your local system.

*NOTE: For online editor, Source Sans Pro are already included; however you will still have to manually upload the `.otf` or `.ttf` files of **Fontawesome** and **Roboto** to your project, by creating a folder `fonts` and put all the `otf` files there. See [Issue](https://github.com/typst/webapp-issues/issues/401)*

### 2. Check Documentation

A [documentation](https://yunanwg.github.io/brilliant-CV/docs.pdf) on CV functions is provided for reference.

### 3. Bootstrap Template

You have two ways to bootstrap the template, according to your need and tech-savvy level.

#### 3.1 With Typst CLI

In your local system, just working like `git clone`, boostrap the template using this command:

```bash
typst init @preview/brilliant-cv:<version>
```

Replace the `<version>` with the latest or any releases (after 2.0.0).

#### 3.2 With `utpm` pakcage manager

[utpm](https://github.com/Thumuss/utpm) is a WIP packager manager for Typst. Install it with official instructions.

Git clone then this repository on your local system, and within the workspace, run `utpm workspace link --force`.

You will have to take care of templating by yourself, though.

### 4. Compile Files

Adapt the `metadata.toml` to suit your needs, then `typst c cv.typ` to get your first CV!

### 5. Beyond

It is recommended to:

1. Use `git` to manage your project, as it helps trace your changes and version control your CV.
2. Use `typstyle` and `pre-commit` to help you format your CV.
3. Use `typos` to check typos in your CV if your main locale is English.
4. (Advanced) Use `LTex` in your favorite code editor to check grammars and get language suggestions.

## How to upgrade version

For the time being, upgrade can be achieved by manually "find and replace" the import statements in batch in your favorite IDE. For example:

```typst
#import "@preview/brilliant-cv:2.0.0" -> #import "@preview/brilliant-cv:2.0.5"
```

**Make sure you read the release notes to notice any breaking changes. We estimate that there would still be some as Typst has not reached to a stable release neither.**

## Migration from `v1`

> The version `v1` is now deprecated, due to the compliance to Typst Packages standard. However, if you want to continue to develop on the older version, please refer to the `v1-legacy` branch.

With an existing CV project using the `v1` version of the template, a migration is needed, including replacing some files / some content in certain files.

1. Delete `brilliant-CV` folder, `.gitmodules`. (Future package management will directly be managed by Typst)
2. Migrate all the config on `metadata.typ` by creating a new `metadata.toml`. Follow the example toml file in the repo, it is rather straightforward to migrate.
3. For `cv.typ` and `letter.typ`, copy the new files from the repo, and adapt the modules you have in your project.
4. For the module files in `/modules_*` folders:
   1. Delete the old import `#import "../brilliant-CV/template.typ": *`, and replace it by the import statements in the new template files.
   2. Due to the Typst path handling mecanism, one cannot directly pass the path string to some functions anymore. This concerns, for example, the `logo` argument in `cvEntry`, but also on `cvPublication` as well. Some parameter names were changed, but most importantly, **you should pass a function instead of a string (i.e. `image("logo.png")` instead of `"logo.png"`).** Refer to new template files for reference.
5. You might need to install `FontAwesome 6`, `Roboto` and `Source Sans Pro` on your local system now, as new Typst package discourages including these large files.
6. Run `typst c cv.typ` without passing the `font-path` flag. All should be good now, congrats!

Feel free to raise an issue for more assistance should you encounter a problem that you cannot solve on your own :)

## Alternatives

If you are not a fan of my approach, you will also have to take a look at:

- [**typst-cv**](https://github.com/munzirtaha/typst-cv): A more minimalistic approach to typesetting this template, thanks [munzirtaha](https://github.com/munzirtaha) for your work!

## Credit

- [**Typst**](https://github.com/typst/typst) is a newborn, open source and simple typesetting engine that offers a better scripting experience than [**LaTeX**](https://www.latex-project.org/).
- [**Awesome-CV**](https://github.com/posquit0/Awesome-CV) is the original LaTeX CV template from which this project is heavily inspired. Thanks [posquit0](https://github.com/posquit0) for your excellent work!
- [**Font Awesome**](https://fontawesome.com/) is a comprehensive icon library and toolkit used widely in web projects for its vast array of icons and ease of integration.
- [**tidy**](https://github.com/Mc-Zen/tidy) is a package that generates documentation directly in Typst for your Typst modules. Keep it tidy!
