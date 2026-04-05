#!/usr/bin/sh

set -e

usage() {
    printf "usage: %s <path/to/typst-packages>\n" $0
}
pkg=packages/preview/abbr

if [ $# -ne 1 ] || [ ! -d $1 ] || [ ! -d $1/$pkg ]
then
    usage
    exit
fi

v=$(awk '/version/ {print substr($3, 2, length($3)-2) }' typst.toml)

if [ $(git describe) != v$v ]
then
    printf "NOT on annotated tag. clean up!\n"
    exit
fi


if [ -d $1/$pkg/$v ]
then
    printf "version directory \"%s\" already exists in %s\naborting...\n" $v $1/$pkg
    exit
fi

msg=`git tag v$v -n99 --format='%(contents)'`
dest=$1/$pkg/$v

mkdir $dest
files=$(git ls-files)
cp $files $dest


cd $dest
git add .
git commit -m"$msg"
printf "check things, then go push\ncd %s\n" $dest
