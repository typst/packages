// Copyright (C) 2024 Casey Dahlin <sadmac@google.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//         http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "@preview/celluloid:0.1.0": *
#show : screenplay.with(
  [Lorem Ipsum],
  author: [John Doe],
  contact: [
    John Doe\
    123 Hickory Street\
    Chicago, IL 12345\
    john.doe\@example.com
  ])

#scene[int][a place][day]

We introduce a character #intro[Jimminy].

#lorem(50)

#dialogue[Jimminy][#parenthetical(lorem(5)) #lorem(10)]

#lorem(10)

#more-dialogue[#lorem(2)]

#lorem(107)

#transition[intercut with]
#scene[int][somewhere elese][day]
#lorem(50)

#title-over[Disco City, 1978]

#dialogue(paren: "O.S.")[Jimminy][#parenthetical(lorem(5)) #lorem(400)]

#lorem(50)

#action[A thing]
Happens suddenly
#action[A character]
Looks on, helpless.
