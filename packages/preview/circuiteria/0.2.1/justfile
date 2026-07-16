# Local Variables:
# mode: makefile
# End:
gallery_dir := "./gallery"
set shell := ["bash", "-uc"]

manual:
  typst c manual.typ manual.pdf

gallery:
  for f in "{{gallery_dir}}"/*.typ; do typst c --root . "$f" "${f%typ}png"; done
