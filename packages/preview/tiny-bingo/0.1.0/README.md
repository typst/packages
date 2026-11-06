# tiny-bingo

A Typst package for generating randomized bingo boards for social events and similar activities.

## Usage

Import the `make-board` function to make a bingo board, possibly also the `read-words` function to read bingo contents from a file.
The randomizer is deterministic, so the seed must be changed to make different boards.
A simple multi-board example is shown below.

```typst
#import "@preview/tiny-bingo:0.1.0": read-words, make-board

#let words = read-words("./words.txt")

#set document(title: "Example use of\nTINY-BINGO")
#let pages = 5
#for i in range(pages) {
  title()
  
  let seed = datetime.today().day() + i
  make-board(words, seed, size: 5, textsize: 8pt)
  
  if i != pages - 1 { pagebreak() }
}
```

## API

- `read-words(path)`: Read a newline-separated list of words from a file and returns it as an array of strings. Handles both LF and CRLF line endings and ignores blank lines.
- `make-board(words, rng-seed, size: 5, free: true, freetext: "FREE!", textsize: none, cell-padding: 2pt)`: Generate a square bingo board of the given size from the provided word list and returns a content grid. Asserts that the word list contains at least `size * size` entries.
    - `words`: Array of strings or other content to use as bingo words.
    - `rng-seed`: Random number generator seed for reproducible results.
    - `size`: Size of the edges of the bingo board (default: 5).
    - `free`: Whether to include a free space in the middle (default: true).
    - `freetext`: Text to display in the free space (default: "FREE!").
    - `textsize`: Font size for the bingo words. Applies to string entries and `text` content, including the free space cell; other content is left unchanged (default: none).
    - `cell-padding`: Padding around each cell (default: 2pt).

## License

This project is licensed under the GNU Affero General Public License v3.0 or later.
