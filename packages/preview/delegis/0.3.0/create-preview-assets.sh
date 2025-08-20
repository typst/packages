#!/bin/bash
# Copyright (c) 2024 WüSpace e. V.
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT
#
# This script creates preview assets for the template.
# It compiles the template using typst and generates demo-{1-3}.png files as well as a thumbnail.png file.

# Check if typst command is available
if ! command -v typst >/dev/null 2>&1; then
	echo "typst is not installed"
	exit 1
fi

# Check if git command is available
if ! command -v git >/dev/null 2>&1; then
	echo "git is not installed"
	exit 1
fi

# Ensure the working directory is the folder containing the .sh
cd "$(dirname "$0")"

# Ensure git status is clean and up-to-date
if ! git diff-index --quiet HEAD --; then
	echo "There are uncommitted changes in the repository"
	exit 1
fi

git fetch
if [[ $(git rev-parse HEAD) != $(git rev-parse @{u}) ]]; then
	echo "The local branch is not up-to-date with the remote branch"
	exit 1
fi

# Run typst compile command
typst compile template/main.typ demo-{n}.png

# Delete demo-{n}.png with {n} > 3 if they exist
for ((n=4; n<=10; n++)); do
	if [[ -f "demo-$n.png" ]]; then
		rm "demo-$n.png"
	fi
done

# Copy demo-3.png to thumbnail.png
cp demo-3.png thumbnail.png

# Commit and push changes
git add .
if git diff-index --quiet HEAD --; then
	echo "No changes to commit"
else
	git commit -m "Update preview assets"
	git push
	echo "Changes were committed and pushed"
fi
