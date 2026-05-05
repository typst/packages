import zippy/ziparchives, std/tables

# This example shows how to easily create an in-memory zip archive that can be
# written to disk or uploaded to a server, etc.

# First, add the entries you want in the zip archive.
# The key is the path (must be relative) and the value is the content bytes.
var entries: Table[string, string]
entries["file.txt"] = "Hello, Zip!"
entries["data/blob.json"] = "{}"

# Creates a zip archive containing the compressed entries.
let archive = createZipArchive(entries)

# This zip archive can be written to disk:
writeFile("tmp.zip", archive)
