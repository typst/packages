test:
    rm -f test/test-*.png
    typst compile test/tests.typ 'test/test-{n}.png' --root . --ppi 200

doc:
    typst compile doc/keyle.typ 'doc/keyle.pdf' --root .

bump $VERSION $FORCE="":
    sed -i 's/^version = .*/version = "'$VERSION'"/g' typst.toml
    sed -i 's/keyle:.*"$/keyle:'$VERSION'"/g' README.md
    sed -i 's/keyle:.*"$/keyle:'$VERSION'"/g' doc/keyle.typ
    @just doc
    git add doc/keyle.pdf doc/keyle.typ README.md typst.toml
    git commit -m 'bump: version '$VERSION
    git tag $FORCE $VERSION -m 'version '$VERSION
    git push $FORCE
    git push $FORCE origin v$VERSION