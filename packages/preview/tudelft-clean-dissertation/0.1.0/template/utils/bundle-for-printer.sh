#!/bin/sh

# run the export commands for the thesis to make sure it is the latest version

sh compile_thesis_for_print.sh

# bundle all files that the printer would need in a single zip file

rm dissertation-files-for-printer.zip
zip -j dissertation-files-for-printer.zip ../propositions/propositions.pdf ../thesis-for-printshop.pdf ../cover/cover-source/cover-spread.pdf ../cover/cover-source/bookmark.pdf