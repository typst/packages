# Migration Guide

## Migration from `v2`
This version introduces a new directory structure and API improvements. While we have implemented backward compatibility, we recommend updating your code to the new standard.

### 1. Update Imports
The package structure has changed. If you were importing specific files, you might need to update the paths. However, the main entry point remains the same.

### 2. Parameter Renaming
We have renamed several parameters to follow the kebab-case convention. The old camelCase parameters are still supported but deprecated.

- `cv`: `profilePhoto` -> `profile-photo`
- `letter`: `myAddress` -> `sender-address`, `recipientName` -> `recipient-name`, `recipientAddress` -> `recipient-address`
- `cv-section`, `cv-entry`: `awesomeColors` -> `awesome-colors`

### 3. Template Updates
If you are using the template, we recommend updating your `cv.typ` and `letter.typ` to use the new parameter names.

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
