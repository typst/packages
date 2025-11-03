# https://github.com/casey/just

watch target='seminar-report':
  typst watch --root . "template/{{target}}.typ"

build target='seminar-report':
  typst compile --root . --pdf-standard a-2b "template/{{target}}.typ"

thumbnail:
  pdftoppm -png template/seminar-report.pdf -r 250 > thumbnail.png
