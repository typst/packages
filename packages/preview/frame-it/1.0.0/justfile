set unstable

readme-typ-file := 'README.typ'

default:
    just --list

setup: setup-pre-commit-hooks && _add-assets-to-git-exclude
    git worktree add assets

[confirm("Add pre-commit hook to .git/hooks/pre-commit?")]
setup-pre-commit-hooks:
    touch .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
    echo "just pre-commit" >> .git/hooks/pre-commit

[confirm("Add new worktree 'assets' to '.git/info/exclude'?")]
_add-assets-to-git-exclude:
    echo assets >> .git/info/exclude

push-new-readme: (readme-compile "assets/README.svg") && commit-and-push-assets

[confirm("Do you want to commit and push all changes on the assets branch?")]
[script]
commit-and-push-assets commit-msg="Update.":
    cd assets
    git add .
    git commit -m {{commit-msg}}
    git push

readme-watch output="":
    typst watch {{readme-typ-file}} {{output}}

readme-compile output="" *options="":
    typst compile {{options}} {{readme-typ-file}} {{output}}

pre-commit: (readme-compile "/dev/null" "-f svg")
    typos
    typstyle --check format-all

_version-regex := '[0-9]+\.[0-9]+\.[0-9]+'
release new-version:
    @echo Testing if index and staging area are empty
    test -z "$(git status --porcelain)"
    sed -Ei 's|#import "@preview/frame-it:{{_version-regex}}"|#import "@preview/frame-it:{{new-version}}"|g' README.typ
    sed -Ei 's|version = "{{_version-regex}}"|version = "{{new-version}}"|g' typst.toml
    git add README.typ typst.toml
    git commit -m "Bump version to {{new-version}}."
    test -z "$(git status --porcelain)" # Just to make sure we didn't screw up
    @echo Don\'t forget to open a pull request for the new version!
