# Update Instructions

- Change all the version numbers from XX.OLD to XX.NEW
- Run the example again 
  - First the full theme (rename to `example_full.pdf`)
    - `typst compile example/example.typ --root=..` from the root folder
  - then the normal theme 
  - -> Commit
- update the linked Example PDFs 
  - replace the commit in the URL with the new one
  - Commit ->
  
- Copy the folder to a new location, name it XX.NEW
- Delete:
  - diaquarto/
  - docs/
  - example/
  - diatypst.code-workspace
- Open new Fork of Typst packages, Drag and Drop the XX.NEW Folder to "File Upload"



