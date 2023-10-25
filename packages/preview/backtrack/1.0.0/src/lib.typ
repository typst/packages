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

#import "versions.typ"

#let current-version = {
  import "checks.typ": *
  // Versions before 2023-03-21 can't run most modern version checks, so we need
  // to check for it first.
  if v2023-03-21-supported {
    if v0-9-0-supported {
      versions.from-v0-9-0-version(sys.version)
    } else if v0-8-0-supported() {
      versions.v0-8-0
    } else if v0-7-0-supported() {
      versions.v0-7-0
    } else if v0-6-0-supported() {
      versions.v0-6-0
    } else if v0-5-0-supported() {
      versions.v0-5-0
    } else if v0-4-0-supported() {
      versions.v0-4-0
    } else if v0-3-0-supported() {
      versions.v0-3-0
    } else if v0-2-0-supported() {
      versions.v0-2-0
    } else if v0-1-0-supported() {
      versions.v0-1-0
    } else if v2023-03-28-supported() {
      versions.v2023-03-28
    } else {
      versions.v2023-03-21
    }
  } else if v2023-02-15-supported() {
    versions.v2023-02-15
  } else if v2023-02-12-supported() {
    versions.v2023-02-12
  } else {
    versions.v2023-01-30
  }
}
