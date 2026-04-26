// Copyright © 2023 Luke Chambers
// This file is part of Backtrack.
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not
// use this file except in compliance with the License. You may obtain a copy of
// the License at <http://www.apache.org/licenses/LICENSE-2.0>.
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
// License for the specific language governing permissions and limitations under
// the License.

#let _v0-9-0-supported = {
  import "checks.typ": v0-9-0-supported
  v0-9-0-supported
}

#let from-v0-9-0-version(v0-9-0-version) = (
  cmpable: v0-9-0-version,
  displayable: str(v0-9-0-version),
  observable: v0-9-0-version,
)

#let post-v0-8-0 = if _v0-9-0-supported {
  (..components) => from-v0-9-0-version(version(..components))
} else {
  (..components) => {
    let flattened = ()
    for component in components.pos() {
      if type(component) == type(()) {
        flattened += component.map(str)
      } else {
        flattened.push(str(component))
      }
    }
    (
      cmpable: 9223372036854775807,
      displayable: flattened.join("."),
      observable: flattened,
    )
  }
}

#let _numbered = if _v0-9-0-supported {
  minor => from-v0-9-0-version(version(0, minor, 0))
} else {
  minor => (
    cmpable: minor - 1,
    displayable: "0." + str(minor) + ".0",
    observable: (0, minor, 0),
  )
}

#let v0-8-0 = _numbered(8)
#let v0-7-0 = _numbered(7)
#let v0-6-0 = _numbered(6)
#let v0-5-0 = _numbered(5)
#let v0-4-0 = _numbered(4)
#let v0-3-0 = _numbered(3)
#let v0-2-0 = _numbered(2)
#let v0-1-0 = _numbered(1)

#let _dated = if _v0-9-0-supported {
  (_, date, date-components) => {
    let version = version(0, 0, 0, date-components)
    (cmpable: version, displayable: date, observable: version)
  }
} else {
  (versions-until-v0-1-0, date, date-components) => (
    cmpable: -versions-until-v0-1-0,
    displayable: date,
    observable: (0, 0, 0) + date-components,
  )
}

#let v2023-03-28 = _dated(1, "2023-03-28", (2023, 3, 28))
#let v2023-03-21 = _dated(2, "2023-03-21", (2023, 3, 21))
#let v2023-02-25 = _dated(3, "2023-02-25", (2023, 2, 25))
#let v2023-02-15 = _dated(4, "2023-02-15", (2023, 2, 15))
#let v2023-02-12 = _dated(5, "2023-02-12", (2023, 2, 12))
#let v2023-02-02 = _dated(6, "2023-02-02", (2023, 2, 2))
#let v2023-01-30 = _dated(7, "2023-01-30", (2023, 1, 30))
