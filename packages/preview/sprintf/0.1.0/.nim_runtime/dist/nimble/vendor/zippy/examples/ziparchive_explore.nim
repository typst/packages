import zippy/ziparchives

# Open the zip archive. This only reads the records metadata,
# it does not read the entire archive into memory.
let reader = openZipArchive("tests/data/ziparchives/Nim-1.6.6.zip")

try:
  # Iterate over the paths in the zip archive.
  for path in reader.walkFiles:
    echo path

  # Extract a file from the archive.
  let contents = reader.extractFile("Nim-1.6.6/doc/readme.txt")
  echo contents
finally:
  # Remember to close the reader when done.
  reader.close()
