# USTC proposal

[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/ustctug/ustc-proposal/main.svg)](https://results.pre-commit.ci/latest/github/ustctug/ustc-proposal/main)
[![github/workflow](https://github.com/ustctug/ustc-proposal/actions/workflows/main.yml/badge.svg)](https://github.com/ustctug/ustc-proposal/actions)

[![github/downloads](https://shields.io/github/downloads/ustctug/ustc-proposal/total)](https://github.com/ustctug/ustc-proposal/releases)
[![github/downloads/latest](https://shields.io/github/downloads/ustctug/ustc-proposal/latest/total)](https://github.com/ustctug/ustc-proposal/releases/latest)
[![github/issues](https://shields.io/github/issues/ustctug/ustc-proposal)](https://github.com/ustctug/ustc-proposal/issues)
[![github/issues-closed](https://shields.io/github/issues-closed/ustctug/ustc-proposal)](https://github.com/ustctug/ustc-proposal/issues?q=is%3Aissue+is%3Aclosed)
[![github/issues-pr](https://shields.io/github/issues-pr/ustctug/ustc-proposal)](https://github.com/ustctug/ustc-proposal/pulls)
[![github/issues-pr-closed](https://shields.io/github/issues-pr-closed/ustctug/ustc-proposal)](https://github.com/ustctug/ustc-proposal/pulls?q=is%3Apr+is%3Aclosed)
[![github/discussions](https://shields.io/github/discussions/ustctug/ustc-proposal)](https://github.com/ustctug/ustc-proposal/discussions)
[![github/milestones](https://shields.io/github/milestones/all/ustctug/ustc-proposal)](https://github.com/ustctug/ustc-proposal/milestones)
[![github/forks](https://shields.io/github/forks/ustctug/ustc-proposal)](https://github.com/ustctug/ustc-proposal/network/members)
[![github/stars](https://shields.io/github/stars/ustctug/ustc-proposal)](https://github.com/ustctug/ustc-proposal/stargazers)
[![github/watchers](https://shields.io/github/watchers/ustctug/ustc-proposal)](https://github.com/ustctug/ustc-proposal/watchers)
[![github/contributors](https://shields.io/github/contributors/ustctug/ustc-proposal)](https://github.com/ustctug/ustc-proposal/graphs/contributors)
[![github/commit-activity](https://shields.io/github/commit-activity/w/ustctug/ustc-proposal)](https://github.com/ustctug/ustc-proposal/graphs/commit-activity)
[![github/last-commit](https://shields.io/github/last-commit/ustctug/ustc-proposal)](https://github.com/ustctug/ustc-proposal/commits)
[![github/release-date](https://shields.io/github/release-date/ustctug/ustc-proposal)](https://github.com/ustctug/ustc-proposal/releases/latest)

[![github/license](https://shields.io/github/license/ustctug/ustc-proposal)](https://github.com/ustctug/ustc-proposal/blob/main/LICENSE)
[![github/languages](https://shields.io/github/languages/count/ustctug/ustc-proposal)](https://github.com/ustctug/ustc-proposal)
[![github/languages/top](https://shields.io/github/languages/top/ustctug/ustc-proposal)](https://github.com/ustctug/ustc-proposal)
[![github/directory-file-count](https://shields.io/github/directory-file-count/ustctug/ustc-proposal)](https://github.com/ustctug/ustc-proposal)
[![github/code-size](https://shields.io/github/languages/code-size/ustctug/ustc-proposal)](https://github.com/ustctug/ustc-proposal)
[![github/repo-size](https://shields.io/github/repo-size/ustctug/ustc-proposal)](https://github.com/ustctug/ustc-proposal)
[![github/v](https://shields.io/github/v/release/ustctug/ustc-proposal)](https://github.com/ustctug/ustc-proposal)

![screenshot](template/images/thumbnail.png)

## Dependencies

- [typst](https://github.com/typst/typst) `>= 0.13.0`

## Usage

```sh
typst init @preview/ustc-proposal
```

## Development

```sh
mkdir -p ~/.local/share/typst/packages/preview/ustc-proposal
cd ~/.local/share/typst/packages/preview/ustc-proposal
git clone --depth=1 https://github.com/ustctug/ustc-proposal 0.0.X
cd 0.0.X/template
```

## Release

```sh
git clone --depth=1 https://github.com/typst/packages
cd package
cp -r ~/.local/share/typst/packages/preview/ustc-proposal packages/preview
rm -rf packages/preview/ustc-proposal/*/.git
git add -A
git commit -mustc-proposal:0.0.X
```

## Related Projects

### USTC proposal template

- [docx](https://cicpi.ustc.edu.cn/indico/conferenceDisplay.py?confId=971)
- [LaTeX](https://github.com/ustctug/thesis_proposal_ustc)
