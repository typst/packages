#!/usr/bin/sh

set -e

usage() {
    printf "usage: %s <new-version>\n" $0
}

v=$(awk '/version/ {print substr($3, 2, length($3)-2) }' typst.toml)

if [ $# -ne 1 ] || [ $1 = $v ]
then
    usage
    exit
fi

if [ -n "$(git status --porcelain)" ]
then
    printf "git dirty. clean up first\n"
    exit
fi

new=$1

for file in README.md example.typ typst.toml
do
    sed s/$v/$new/ -i $file
    git add $file
done

git commit -m"bump version"

shortlog=$(git shortlog v$v..HEAD)
tagmsg=$(printf "Release version %s\n\n%s" "$new" "$shortlog")

git tag -a v$new -e -m "$tagmsg"
