# typst-rcv

RCV ballot papers for Typst.

## Usage

```typst

#import "@preview/typst-rcv:0.1.0": ballot_template, choices
#set document(title: [ RCV Ballot ])
#show: ballot_template

# Contest 1

#choices([ Choice 1 ], [ Choice 2 ])
```

> [!TIP]
> `choices()` can be used by itself without the template.

## License

```
Copyright (C) 2026 Reese Armstrong

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```
