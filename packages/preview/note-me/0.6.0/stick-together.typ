// https://gist.github.com/PgBiel/2976c9d0ed5638ef57633ce7233928ea

// MIT No Attribution
// 
// Copyright (c) 2023 Pg Biel
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the "Software"), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// Attempts to ensure the two elements will be in the same page.
// The threshold specifies how early a pagebreak should be forced.
// That is, the minimum vertical space that both elements should
// have available in the same page; if they have less than that
// threshold, they are moved to the next page.
// A higher threshold means that a pagebreak is forced earlier.
// When using with tables, a threshold of at least the height
// of the heading + the header row + a little bit should be used
// to ensure the header rows won't be alone.
// E.g. 5em could be good for a small table, but you will have to fiddle
// with it (make sure to test it by pushing your table to the bottom and seeing
// how early the elements are moved to the next page).
#let stick-together(a, b, threshold: 3em) = {
  block(a + v(threshold), breakable: false)
  v(-1 * threshold)
  b
}