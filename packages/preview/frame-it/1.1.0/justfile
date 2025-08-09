set unstable

readme-typ-file := 'README.typ'

default:
    just --list


# –––––– [ Dev ] ––––––
pre-commit: (readme-compile-svgs)
    typos
    typstyle --check {{readme-typ-file}} \
        $(git diff-index --cached --name-only HEAD | grep '\.typ') \
        > /dev/null

# –––––– [ Release ] ––––––
_version-regex := '[0-9]+\.[0-9]+\.[0-9]+'
release new-version:
    @echo Testing if index and staging area are empty
    test -z "$(git status --porcelain)"
    sed -Ei 's|#import "@preview/frame-it:{{_version-regex}}"|#import "@preview/frame-it:{{new-version}}"|g' {{readme-typ-file}}
    sed -Ei 's|version = "{{_version-regex}}"|version = "{{new-version}}"|g' typst.toml
    sed -i "s/CURRENT/1.1.0/" CHANGELOG.md
    git add {{readme-typ-file}} typst.toml CHANGELOG.md
    git commit -m "Bump version to {{new-version}}."
    test -z "$(git status --porcelain)" # Just to make sure we didn't screw up
    git tag -a {{new-version}}
    @echo Don\'t forget to open a pull request for the new version!


# –––––– [ Readme ] ––––––
push-new-readme: (readme-compile-svgs) && commit-and-push-assets

[confirm("Do you want to commit and push all changes on the assets branch?")]
[script]
commit-and-push-assets commit-msg="Update.":
    cd assets
    git add .
    git commit -m {{commit-msg}}
    git push

readme-watch:
    typst watch {{readme-typ-file}}

readme-compile theme="light":
    typst compile --input theme={{theme}} {{readme-typ-file}}

readme-compile-svgs:
    typst compile -f svg {{readme-typ-file}} assets/README-{p}.svg
    typst compile -f svg --input theme=dark {{readme-typ-file}} assets/README-dark-{p}.svg


# –––––– [ Setup ] ––––––
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

