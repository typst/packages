# gairm-import reference

The [README](README.md) is the guide. This file is the reference
for every export, and says each thing once. Its examples build on the
`member` schema under [Constructors](#constructors) and the `team`
schema under [Schema paths and edits](#schema-paths-and-edits).

- [Running](#running)
  - [Error records](#error-records)
  - [The model](#the-model)
- [Constructors](#constructors)
  - [Schema nodes](#schema-nodes)
- [Formats](#formats)
- [Schema paths and edits](#schema-paths-and-edits)
- [Introspection](#introspection)
- [JSON Pointer](#json-pointer)
- [JSON Schema translation](#json-schema-translation)
  - [Supported keywords](#supported-keywords)
  - [Out of scope](#out-of-scope)
  - [Deviations from draft 7](#deviations-from-draft-7)
  - [A stricter JSON Resume](#a-stricter-json-resume)

The examples assume the whole package is imported:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:1.0.0": *
```
<!-- x-release-please-end -->

## Running

| Function | Returns |
|---|---|
| `validate(schema, data, strict-null: false)` | every problem found, as an array of error records; `()` when `data` is valid |
| `coerce(schema, data, strict-null: false)` | the model of `data`, without checking it first; panics only where the data leaves no model at all |
| `parse(schema, data, strict-null: false)` | the model, after validating; panics with every problem found |
| `format-errors(errors)` | `parse`'s report for the records `validate` returned, as a string |

`data` is the document, or where to read it; see
[Input forms](README.md#input-forms). The schema comes first, so
`parse.with(schema)` is a parser for one schema. `strict-null` decides
whether JSON `null` is an absent key (off) or a value (on); see
[Null handling](README.md#null-handling).

Each call checks the whole schema first: a non-schema argument, or a
hand-built node that breaks its constructor's rules, panics naming its
path.

A document may nest about 37 levels deep (about 18 through `any-of` /
`one-of`), a translated schema about 34 (17 through `anyOf` / `allOf` /
an `if` beside other keywords), and a schema built in Typst about 70;
past that, Typst fails with `maximum function call depth exceeded`.

### Error records

An error record is `(path, code, message, expected, got)`:

- `path` is where in the document the problem is, as a data path of keys
  and array indices (`("work", 0, "url")`); for a missing key (`required`,
  `dependent`) it is the key that is missing, and `()` is the root. A
  missing key the object requires is reported once, as `required`, and
  never also as `dependent`; one it doesn't require gets a `dependent`
  record for each present key that requires it;
- `code` says what kind of problem it is, from the table below;
- `message` says it in words, without the path: `expected string, got
  integer.`;
- `expected` and `got` hold the data behind the message, or `none` where
  a code has nothing to put there.

Branch on `code`, not on the message:

| `code` | Meaning | `expected` | `got` |
|---|---|---|---|
| `type` | Wrong JSON type (also: an enum or union none of whose members takes that type) | The type name, or for an enum or union the names it takes, null aside, joined by "or" (`"string or number"`) | The value's type name |
| `required` | A required key is missing | | |
| `unknown-key` | A key the object does not declare | The valid keys | The key |
| `dependent` | A key required by another key's presence is missing | The rule broken, the trigger's entry: `(dependent-required: (card: ("billing",)))` | |
| `enum` | Not one of the enum's values | The values | The value |
| `format` | Not in the format's shape (date, email, …) | The format's description | The value |
| `pattern` | Does not match the pattern | `string()`'s `expected`; for a translated `pattern`, `matching "<pattern>"`; else `"matching pattern"` | The value |
| `length` | String too short or too long | The bound broken: `(min-length: 3)` or `(max-length: 80)` | The length |
| `range` | Number out of range | The bound broken: `(minimum: 1)`, `(exclusive-minimum: 1)`, `(maximum: 10)` or `(exclusive-maximum: 10)` | The number |
| `multiple` | Not a multiple of `multiple-of` | `(multiple-of: 0.1)` | The number |
| `integer` | A fractional number where an integer is expected | | The number |
| `items` | Too few or too many array items | The bound broken: `(min-items: 1)` or `(max-items: 5)` | The item count |
| `unique` | Duplicate array items | | The two duplicate indices |
| `union` | Several alternatives take the value's type but none matches, or more than one `one-of` member matches | The members' kinds, null aside, as an array (`("string (date)", "integer")`) | |
| `not` | The value matches a `not-of` schema | | |

`path-to-pointer(record.path)` gives the record's location as a JSON
Pointer. `format-errors` and `parse`'s report write a path as `work[0].url`,
quoting a key that is not a plain name in brackets (`["a.b"].c`,
`[""]`), so no two paths read alike.

### The model

`coerce` and `parse` return the document as the schema describes it:

| Schema | Model |
|---|---|
| `string(..)` | the string; a Typst `datetime` only in a `date` field (see [Formats](#formats)) |
| `markup()` | the string as Typst `content` |
| `number(..)`, `integer(..)` | the number as given, an int, a float or a Typst `decimal`: an `integer` field keeps `1.0` as a float |
| `boolean()`, `null()`, `enum-of(..)`, `const-of(..)` | the value as given |
| `unknown()` | the value as given, nested values included |
| `array-of(..)` | each item's model; absent (null) items dropped |
| `object(..)` | each declared key's model, absent keys dropped. Undeclared keys are dropped, passed through as given (`additional: true`), or modelled by the `additional` schema. A free-form object (no fields, `additional: true`) is kept as given, nulls included |
| `any-of(..)`, `one-of(..)` | the model of the first member that matches; when none matches, the model of the first member that takes the value's type and leaves one, as `coerce` would build it alone |
| `not-of(..)` | the value as given |
| `if-of(..)` | the model of the branch the condition picks, or the value as given when that branch is left out |

## Constructors

A schema is a plain dictionary with a `kind`, built by functions. As with
Typst's own functions (`text(size:)`), the options are named arguments, and
an argument you leave out sets nothing. Each constraint argument is the
JSON Schema keyword of the same meaning in kebab-case (`min-length` is
`minLength`), checked by the same rule the translator applies: a value of
the wrong type, or bounds no value can satisfy, panics when the schema is
built.

| Constructor | Arguments | Accepts |
|---|---|---|
| `string(..)` | `min-length`, `max-length`, `format`, `pattern`, `expected` | a string |
| `number(..)` | `minimum`, `maximum`, `exclusive-minimum`, `exclusive-maximum`, `multiple-of` | an int, a float or a Typst `decimal` |
| `integer(..)` | the same as `number` | a number with no fractional part (`1.0` passes, `1.5` fails) |
| `array-of(elem, ..)` | `min-items`, `max-items`, `unique-items` | an array whose every item matches `elem` |
| `object(shape, ..)` | `required-keys`, `dependent-required`, `additional` | a dictionary with the fields in `shape` |
| `map(value-schema, ..)` | `required-keys` | a dictionary with any keys, every value matching `value-schema` |
| `any-of(a, b, …)` | | a value matching at least one member |
| `one-of(a, b, …)` | | a value matching exactly one member |
| `not-of(member)` | | a value that does not match `member` |
| `if-of(cond, ..)` | `then`, `otherwise` | a value that matches `then` if it matches `cond`, and `otherwise` if not |
| `nullable(member)` | | `null` or a value `member` accepts (see [Null handling](README.md#null-handling)) |
| `enum-of(a, b, …)` | | one of the values, which may mix types |
| `const-of(value)` | | `value` only; the same as `enum-of((value,))` |
| `boolean()` | | `true` or `false` |
| `null()` | | `null`, under `strict-null: true`; by default a `null` key counts as absent |
| `markup()` | | a string, returned as Typst `content` so it splices into markup |
| `unknown()` | | any value, passed through unchanged (JSON Schema `{}`) |

- `min-length` and `max-length` count characters as grapheme clusters.
- `format` takes one of the nine names under [Formats](#formats).
- `pattern` takes a `regex` or a pattern string (an invalid one fails
  with Typst's regex error); `expected` says what a
  match looks like, for the error message (default `"matching pattern"`),
  and is only allowed with a `pattern`. With a `format` as well, the
  string must have the format and match the pattern.
- `any-of` and `one-of` take their members as separate arguments or as one
  array: `any-of(a, b)` equals `any-of((a, b))`.
- `enum-of` takes its values the same way: `enum-of("a", "b")` equals
  `enum-of(("a", "b"))`, and a lone array value is written
  `enum-of(((1, 2),))`.
- `if-of` is JSON Schema's `if` / `then` / `else`, with the else branch
  named `otherwise` (`else` is a Typst keyword). It takes `then`,
  `otherwise` or both; a branch left out accepts the value as it is. Only
  whether the value matches `cond` counts: `cond`'s errors are never
  reported, and the branch it picks gives the errors and the model.
  An `object()` condition, or `not-of` member, is closed like any other:
  pass `additional: true` to match objects with more keys.
  `if-of(string(min-length: 5), then: string(pattern: "^x"))` accepts
  `"abc"` and `"xyzzy"`, and rejects `"abcde"`.
- `number` and `integer` take each bound and `multiple-of` as an int, a float or a Typst `decimal`.
- `integer`'s bounds must leave a whole number between them:
  `integer(minimum: 1.5, maximum: 1.7)` panics.
- `object`'s `additional` says what to do with keys not in `shape`:
  `none` (the default) or `false` rejects them, `true` lets them through
  unchecked, and a schema checks each one against it. `required-keys` lists
  the keys that must be present, and `dependent-required` maps a key to the
  keys that must be present whenever it is; a key listed twice counts
  once. A key holding `null` counts as absent for both unless
  `strict-null` is on.

```typst
#let member = object(
  (
    name: string(min-length: 1, max-length: 80),
    email: string(format: "email"),
    homepage: string(format: "uri"),
    joined: string(format: "date"),
    code: string(pattern: "^[A-Z]{3}$", expected: "a three-letter code"),
    age: integer(minimum: 0),
    rating: number(minimum: 0, maximum: 5, multiple-of: 0.5),
    tags: array-of(string(), min-items: 1, unique-items: true),
    phone: string(),
  ),
  required-keys: ("name", "email"),
  dependent-required: (phone: ("email",)),
)
```

### Schema nodes

A schema is a dictionary: its `kind`, then a field per argument given,
named as the argument is, plus the fields below. These names are part of
the API, so hand-built nodes and `schema-update` functions may use them.

| `kind` | Built by | Other fields |
|---|---|---|
| `string`, `number`, `integer`, `boolean`, `null`, `markup`, `unknown` | the constructor of that name | none; a `pattern` is stored as a `regex` |
| `enum` | `enum-of`, `const-of` | `values`, an array |
| `array` | `array-of` | `elem` |
| `object` | `object`, `map` | `shape`; `required-keys`, `dependent-required` and `additional` only when set. `map(x)` is `shape: (:)`, `additional: x` |
| `union` | `any-of`, `one-of`, `nullable` | `members`, and `exclusive`: true for `one-of`. `nullable(x)` is the members `(x, null())` |
| `not` | `not-of` | `member` |
| `if` | `if-of` | `cond`, and `then` / `otherwise` when set |

A field another kind reads (`min-length` on an array), `integer` on a
number, `else` on an `if`, or a field the kind reads set to `none`
(but `additional`, where `none` means closed), panics at the schema
check: leave a field out to unset it. Any other field is an annotation
and rides along unchecked, so a misspelt one (`formt`) checks nothing.

## Formats

`string(format: …)` gates a string with a regex. `date`, `date-time` and
`time` are RFC 3339's, as draft 7 defines them. The others are
deliberately permissive: they reject obvious malformations without
claiming full RFC compliance.

| `format` | Accepts | Error hint |
|---|---|---|
| `date` | `YYYY-MM-DD`, a day its month has (`2024-02-29`, not `2023-02-29`) | `an RFC 3339 date (e.g. "2024-01-15")` |
| `date-time` | a `date`, `T`, `HH:MM:SS`, an optional fraction, then a `Z` or `±HH:MM` offset | `an RFC 3339 date-time (e.g. "2024-01-15T10:00:00Z")` |
| `time` | `HH:MM:SS`, an optional fraction, then a `Z` or `±HH:MM` offset | `an RFC 3339 time (e.g. "10:00:00Z")` |
| `uri` | any scheme, `:`, then no whitespace (`https://…`, `mailto:…`, `urn:…`) | `a URI (e.g. "https://example.com")` |
| `email` | a local part (or a quoted one), `@`, a domain of one or more labels or an address literal (`name@[127.0.0.1]`) | `an email (e.g. "name@example.com")` |
| `uuid` | 8-4-4-4-12 hex digits, any case | `a UUID (e.g. "123e4567-e89b-12d3-a456-426614174000")` |
| `hostname` | dot-separated labels of letters, digits and inner hyphens | `a hostname (e.g. "example.com")` |
| `ipv4` | a dotted quad, octets 0-255, no leading zeros | `an IPv4 address (e.g. "192.0.2.1")` |
| `ipv6` | hex groups with `::` compression; no embedded-IPv4 tail | `an IPv6 address (e.g. "2001:db8::1")` |

A partial date (`2024-01`) or a time with no offset is not one of these
formats; check it with a `pattern`.

A miss reports `expected <hint>.` at the field's path. For `member`:

```typst
#format-errors(validate(member, (
  name: "Ada",
  email: "ada",
  homepage: "example.com",
  joined: "2024/01/15",
)))
```

```text
gairm-import: found 3 problems in the input:
  - email: expected an email (e.g. "name@example.com").
  - homepage: expected a URI (e.g. "https://example.com").
  - joined: expected an RFC 3339 date (e.g. "2024-01-15").
```

Data written in Typst can give a `date` field a `datetime` with a date and
no time; it is returned as the ISO string (`"2024-01-05"`). One with a
time, or with a year outside 0–9999, is rejected rather than truncated. A
`date-time` field takes no `datetime`: a Typst `datetime` has no offset,
which the format requires; in any other string field it is a `type`
error.

A `pattern` is a Typst regex, and matches anywhere in the string: anchor it
with `^…$` for a full-string match.

## Schema paths and edits

A *schema path* names one node in a schema, as an array of segments.
It is not a *data path*, the keys and indices an error record's `path`
holds, which name a place in the document. Every function below takes a
schema path. Its segments are:

| Segment | Enters |
|---|---|
| a field name (`"basics"`) | that field of an object; an int names the field it spells, as `pointer-to-path` reads `/2024` |
| `"items"` | an array's item schema |
| `"additionalProperties"` | an object's `additional` schema (only when it is a schema, not `true`) |
| an int (`0`) | that member of an `any-of` or `one-of` |
| `0` in a `nullable(X)` | `X` |
| `"not"` | a `not-of` member |
| `"if"`, `"then"`, `"else"` | an `if-of`'s condition, or a branch it has (`"else"` is `otherwise`) |

`()` is the whole schema. A field literally named `"additionalProperties"`
wins over the keyword; reach the additional schema in that case with
`schema-update` on the parent. Paths join with `+`.

| Function | Returns |
|---|---|
| `schema-get(schema, at)` | the node at `at` |
| `schema-put(schema, at, value)` | the schema with the node at `at` replaced by `value` |
| `schema-update(schema, at, fn)` | the schema with the node at `at` replaced by `fn(node)` |
| `add-field(schema, at, sub-schema, required: false)` | the schema with a new field at `at`, required if `required: true` |
| `remove-field(schema, at)` | the schema without the field at `at`, which also leaves `required-keys` and `dependent-required` |
| `set-required(schema, at, keys)` | the object at `at` also requiring `keys`, after those it already requires |
| `unset-required(schema, at, keys)` | the object at `at` no longer requiring `keys` |

Every edit returns a new schema and leaves its input alone. The schema
comes first, so edits chain through `.fold`. A node written by `schema-put`
or returned by `schema-update`'s function must be a schema, and every object
an edit touches is rebuilt through `object()`, so an edit cannot break its
invariants. A missing path or field, adding a field that exists,
requiring a key a closed object does not declare, or unsetting one it
does not require panics, naming the function and what failed.

`add-field` and `remove-field` take the field's own path, its object's
path plus its name, so a `find-paths` result folds straight into
`remove-field`. `set-required` adds to `required-keys`; to replace the
list, use `schema-update(s, at, o => (..o, required-keys: keys))`.

The examples edit `team`, a schema built on `member` from
[Constructors](#constructors):

```typst
#let team = object(
  (
    name: string(),
    lead: nullable(string()),
    members: array-of(member),
    contact: one-of(
      string(format: "email"),
      object((phone: string()), required-keys: ("phone",)),
    ),
  ),
  required-keys: ("name", "members"),
)

// A field a renderer adds.
#let with-logo = add-field(team, ("logo",), string(format: "uri"))

// A role on every member, required.
#let with-role = add-field(
  team,
  ("members", "items", "role"),
  enum-of(("lead", "dev")),
  required: true,
)

// Members' names as content, so they splice into markup.
#let content-names = schema-put(
  team,
  ("members", "items", "name"),
  markup(),
)

// Spreading a member keeps everything it doesn't change.
#let open-members = schema-update(
  team,
  ("members", "items"),
  m => (..m, additional: true),
)

// Require a member's joining date, then relax it again.
#let dated = set-required(team, ("members", "items"), ("joined",))
#let undated = unset-required(dated, ("members", "items"), ("joined",))
```

`add-field` keeps everything else about the object, its `additional` and
`required-keys` included. Splicing the shape into a new object,
`object((..team.shape, logo: …))`, does not: the new object requires
nothing, and `object()` rejects undeclared keys by default, so it would
also close an object that was open.

Folding `find-paths` into `schema-put` edits every node of a kind at once,
and covers fields a future schema adds. Paths come parents first, so
fold over `.rev()` when an edit changes what is below the node (stripping
nested `nullable`s):

```typst
#let corporate-uri = string(
  pattern: "^https://(corp|docs)\.example\.com/",
  expected: "a corporate URL",
)
#let corporate-schema = find-paths(team, string(format: "uri")).fold(
  team,
  (schema, path) => schema-put(schema, path, corporate-uri),
)
```

## Introspection

`describe-schema(schema)` draws a schema as an indented tree, one line per
field with its kind:

- keys sort alphabetically, so diffs across schema versions stay stable,
  and a key that is not a plain name is quoted (`"a.b"`);
- a required field is suffixed `*`, an array `[]` (`[][]` for an array of
  arrays), and `*` as a key stands for any other key (the `additional`
  schema);
- a required key the shape doesn't declare is listed as `key*` with the
  `additional` schema (`unknown` for `additional: true`);
- an object with no fields that takes no other keys shows as `empty object`;
- constraints follow the kind in brackets, a format or an enum's values in
  parentheses, and a pattern as `+ pattern`;
- a union lists its members as `[0]`, `[1]`, … under `any of:` or
  `one of:`, `nullable(X)` draws as `X?`, a `not-of` member shows as
  `not`, and an `if-of`'s condition and branches as `if`, `then` and
  `else`;
- an object's `dependent-required` entries close its block as
  `trigger → dependents`.

For `member` from [Constructors](#constructors):

```text
age       integer (minimum 0)
code      string + pattern
email*    string (email)
homepage  string (uri)
joined    string (date)
name*     string (min-length 1, max-length 80)
phone     string
rating    number (minimum 0, maximum 5, multiple-of 0.5)
tags[]    string (min-items 1, unique-items)
phone → email
```

And `team` from [Schema paths and edits](#schema-paths-and-edits), with `member`
nested under `members[]`:

```text
contact  one of:
  [0]  string (email)
  [1]:
    phone*  string
lead     string?
members*[]:
  age       integer (minimum 0)
  …
  tags[]    string (min-items 1, unique-items)
  phone → email
name*    string
```

A conditional, `if-of(string(min-length: 5), then: string(pattern: "^x"),
otherwise: number())`:

```text
if    string (min-length 5)
then  string + pattern
else  number
```

`find-paths(schema, query)` lists the path of every node matching
`query`, inside union, `not-of` and `if-of` members too, sorted as above.
The paths use the segments under [Schema paths and edits](#schema-paths-and-edits), so
they work wherever a schema path does. A query is:

- a schema node, which matches the nodes of its kind that have every field
  the query sets, with the same value: `string()` finds every string,
  `string(format: "date")` only the date strings, `number()` numbers but
  not integers, and `number(minimum: 0)` only numbers with that minimum.
  `string(pattern: p)` sets no `expected`, so it finds every string with
  pattern `p`, whatever its message;
- or a constructor, which matches the nodes it builds: `enum-of` every
  enum, `const-of` the single-value ones, `any-of` the inclusive unions
  (a nullable is one), `one-of` the exclusive ones, `nullable` the
  nullable ones, and the rest (`string`, `boolean`, `not-of`, …) every
  node of their kind.

`object`, `map` and `array-of`, as a constructor or a node, are walked
through, not searched for, and panic as a query. An `additional` schema shadowed by a field literally named
`"additionalProperties"` has no path, so it is not searched; reach it
with `schema-update` on its object.

```typst
#find-paths(team, string(format: "email"))
// → (("contact", 0), ("members", "items", "email"))
#find-paths(member, number())
// → (("rating",),)
#schema-get(team, ("contact", 0)).format
// → "email"
```

## JSON Pointer

`path-to-pointer` and `pointer-to-path` convert between path arrays and
[RFC 6901](https://datatracker.ietf.org/doc/html/rfc6901) JSON Pointers:

```typst
#path-to-pointer(("basics", "email"))            // "/basics/email"
#path-to-pointer(("work", 0, "highlights", 1))   // "/work/0/highlights/1"
#path-to-pointer(("a/b",))                       // "/a~1b"     — `/` escapes as `~1`
#path-to-pointer(("~tilde",))                    // "/~0tilde"  — `~` escapes as `~0`

#pointer-to-path("/work/0/highlights/1")         // ("work", 0, "highlights", 1)
#pointer-to-path("")                             // ()          — whole document
#pointer-to-path("/")                            // ("",)       — empty-string key at root
```

An error record's `path` addresses the **data**, so its pointer is one any
JSON Pointer tool can resolve against the document. A schema path
encodes segment for segment (`("work", "items")` → `/work/items`):
neither a data pointer nor a JSON Schema location.

A segment that is not a `str` or a non-negative `int`, or a pointer with
no leading `/` or a `~` escape other than `~0` and `~1`, panics.
`pointer → path → pointer` round-trips exactly; `path → pointer → path`
does too, except that a string segment that looks like an array index
(`("0",)`) comes back as an int (`(0,)`). Only `0` or a number without a
leading zero that fits a 64-bit int reads as an index; `"00"`, `"-0"` and
larger numbers stay strings.

## JSON Schema translation

`schema-from-json-schema(doc)` translates a JSON Schema document (a
dictionary, `path(..)` or bytes) into a schema. It supports a subset of
draft 7, and panics, naming the keyword and where it is (`at
/properties/a: …`, a JSON Pointer), on anything it would otherwise have
to drop.

```typst
#let book-schema = schema-from-json-schema(path("book-schema.json"))
#let book = coerce(book-schema, json("book.json"))
```

The constraint keywords become the fields the constructor arguments set,
so `schema-from-json-schema((type: "string", minLength: 3))` equals
`string(min-length: 3)`.

### Supported keywords

- `type`: `string`, `number`, `integer`, `array`, `object`, `boolean`,
  `null`, or an array of them. `[X, "null"]` becomes `nullable(X)`; any
  other array becomes an `any-of` with one member per type (`null` last),
  each type-specific keyword applying only to its own type's member.
- No `type`: a node with no type-specific keyword (`{}`, or annotations
  only) is `unknown()`. With type-specific keywords (`{minLength: 2}`) it is
  an `any-of` over boolean, object, array, number, string and null, each
  keyword narrowing only its own type's member; the object member is open
  unless the node has `properties` or `additionalProperties`.
- Strings: `minLength`, `maxLength`, `pattern`, and `format` (the nine
  under [Formats](#formats)). With both `format` and `pattern`, both
  apply.
- Numbers: `minimum`, `maximum`, `exclusiveMinimum`, `exclusiveMaximum`
  (as numbers, draft 7's form; draft 4's `true` / `false` panics),
  `multipleOf`.
- Arrays: `items` (a single schema; no `items` takes any item),
  `minItems`, `maxItems`, `uniqueItems`.
- Objects: `properties`, `required`, `additionalProperties` (a schema,
  `true` or `false`; `{}` is `true`), `dependentRequired`, and draft 7's array form of
  `dependencies`, which means the same.
- `enum` and `const` become `enum-of` and `const-of`. `type` and
  constraint keywords beside them are folded in at translate time: only
  the values that satisfy them are kept, and a keyword leaves values of
  other types alone (`minimum` ignores a string). With both, only the
  `enum` values equal to the `const` are kept.
- `anyOf`, `oneOf` and `not` become `any-of`, `one-of` and `not-of`.
  `not` is only a test, so its objects are open, as in `if` (below).
- `allOf` of object schemas is merged at translate time: the properties
  and `required` lists union, a key in two members must have the same
  schema, `additionalProperties` must agree (a member without it counts as
  closed), and members that set it to `false` or a schema must declare
  the same properties. A `type: ["object", "null"]` member merges as its object;
  the result is nullable only if every member is.
- `if`, `then` and `else` become `if-of`. With no other keywords on the
  node, the branches are `then` and `else` as written, of any kind. Beside
  other keywords, each branch is the `allOf` of those keywords and the
  branch, merged as above, and a missing branch is those keywords alone:
  the node and each branch must be object schemas (siblings that are
  only `type: "object"` just give each branch its type). A branch takes the
  node's `type`, and, unless it sets `additionalProperties`, the node's
  `properties` and `additionalProperties`, so `then: {required: ["b"]}`
  requires a property the node declares. A branch that is a `$ref` or a
  composition is merged as written and borrows nothing, so it must be an
  object schema itself. `if` is only a test, so every
  object in it without `additionalProperties` is open, as draft 7 reads
  it. `if` with neither `then` nor `else` checks nothing and is dropped.
- `$ref` to a fragment in the same document (`#/definitions/…`,
  `#/$defs/…`), percent-decoded and then read as a JSON Pointer, so a
  numeric segment can index an array (`#/definitions/pair/anyOf/0`).
- Annotations, accepted and ignored: `$schema`, `$id`, `$comment`,
  `title`, `description`, `default`, `examples`, `readOnly`, `writeOnly`,
  `deprecated`, `definitions`, `$defs`.

`minLength`, `maxLength`, `minItems` and `maxItems` take a non-negative
integer below 2^63; a whole-number float (`2.0`) counts.

### Out of scope

Each of these panics with a message naming it:

- `dependentSchemas`, and the schema form of `dependencies`;
- `additionalItems`, `contains`, `minProperties`, `maxProperties`,
  `patternProperties`, `propertyNames`, `contentMediaType`,
  `contentEncoding`, and any keyword not listed above, a misspelling like
  `minLenght` included;
- boolean schemas (`properties: {a: true}`, `items: false`) and the array
  form of `items`;
- `$ref` outside the document, to the root (`#`), to a named
  anchor, or one that refers back to itself: a translated schema is a
  finite tree, so a recursive schema (a tree of nodes, a list of lists)
  cannot be translated;
- formats other than the nine (see below for a way to drop them);
- `allOf` with non-object members or with closed members that declare
  different properties, and the same of `if` / `then` / `else` beside
  other keywords (move those keywords into `then` and `else`);
- a keyword beside `allOf`, `anyOf`, `oneOf`, `not` or `$ref` other than
  an annotation (move it into the members or the definition), `if`
  included;
- `properties`, `required`, `additionalProperties`, `items` or the
  dependency keywords beside `enum` / `const`, and an `enum` / `const`
  that no value survives;
- a keyword that does not apply to any of a node's `type`s
  (`{type: "string", minItems: 2}`);
- `type: "object"` with neither `properties` nor `additionalProperties`;
  say `additionalProperties: true` for an open object;
- `then` or `else` without `if`;
- `null` as a keyword's value (`type: null`), except in an annotation and
  `const: null`.

An invalid regex in `pattern` fails with Typst's own regex error, which
the translator cannot catch.

Real-world schemas often use formats outside the nine (`uri-reference`,
`regex`, `idn-email`, …). Draft 7 lets a validator skip a format it
does not check, so dropping them before translating keeps every other
constraint:

```typst
#let checked = ("date", "date-time", "time", "uri", "email", "uuid",
  "hostname", "ipv4", "ipv6")
// Every `format` outside the nine, removed. A property that happens to
// be named "format" holds a schema, not a string, so it stays.
#let drop-formats(js) = if type(js) == dictionary {
  let js = js.pairs().map(((k, v)) => (k, drop-formats(v))).to-dict()
  let f = js.at("format", default: none)
  if type(f) == str and f not in checked { let _ = js.remove("format") }
  js
} else if type(js) == array { js.map(drop-formats) } else { js }

#let schema = schema-from-json-schema(drop-formats(json("schema.json")))
```

### Deviations from draft 7

Everything under [Out of scope](#out-of-scope) panics where draft 7
would accept or ignore it. Beyond that:

- **`null` is absent by default.** A key holding `null` is treated as
  missing and dropped from the model, and a `null` array item is dropped,
  instead of being checked as a value. `strict-null: true` restores draft
  7's reading. A document that is `null` panics in both modes.
- **A missing `additionalProperties` is closed.** Draft 7 lets undeclared
  keys through unless `additionalProperties` says otherwise; here they are
  rejected unless it is `true` or a schema, and an `allOf` member without
  `additionalProperties` counts as closed (except inside `if` or `not`;
  see [Supported keywords](#supported-keywords)). So `required` or
  `dependencies` naming a key a closed object doesn't declare panics:
  declare it in `properties`. And since a `oneOf`'s object members are
  closed, it can pass a value that draft 7 sees matching several of them.
- **Unknown formats panic, and known ones are asserted.** Draft 7 treats
  `format` as an annotation that a validator may check; here the nine
  formats are always checked, with permissive regexes rather than full RFC
  grammars, and any other format panics.
- **`pattern` is a Typst regex**, not ECMA-262: there is no look-around and
  no backreference, and `\d` and `\w` match Unicode digits and letters.
- **String length counts grapheme clusters**, not code points: `"é"`
  written as `e` plus a combining accent has length 1.
- **`multipleOf` compares numbers as written**, as decimals, so `0.3` is
  a multiple of `0.1`; only a float no decimal can hold (past ±2^96)
  falls back to a ratio within a relative 1e-9 of a whole number.
- **`uniqueItems` compares items as the model holds them**: by default a
  null key is dropped, so under an object schema `{"a": 1, "b": null}` and
  `{"a": 1}` are duplicates. A free-form object (`additionalProperties:
  true` and nothing declared) keeps its nulls, so there they differ.
- **`$id` sets no base URI**, so `$ref` resolves against the document
  root only: the root's `$id` is ignored, and one below the root panics
  unless it is empty or only a fragment (`#foo`).
- **Bounds no value meets panic** (`minLength` above `maxLength`), even
  where another `type` in the list could still pass; only an `integer`
  whose bounds hold no whole number is dropped from the list instead.

### A stricter JSON Resume

[JSON Resume](https://jsonresume.org/schema)'s schema leaves its objects
open and its dates partial. To report a misspelt key, check full dates
and make the free-text fields Typst `content`, edit the document before
translating it and the schema after:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:1.0.0": (
  parse, schema-from-json-schema, schema-put, markup,
)

// Not for schemas with `not` or `if`: closing an object there loosens them.
#let close(js) = if type(js) == dictionary {
  let js = js.pairs().map(((k, v)) => (k, close(v))).to-dict()
  if (
    "properties" in js and js.at("additionalProperties", default: true) == true
  ) {
    js.additionalProperties = false
  }
  js
} else if type(js) == array { js.map(close) } else { js }

#let strict-json = {
  let js = close(json("resume.schema.json"))
  // A full date, or the year and month JSON Resume also allows.
  js.definitions.iso8601 = (
    anyOf: (
      (type: "string", format: "date"),
      (type: "string", pattern: "^[0-9]{4}(-(0[1-9]|1[0-2]))?$"),
    ),
  )
  js
}

#let resume-schema-strict = (
  ("objective",),
  ("basics", "summary"),
  ("work", "items", "summary"),
  ("work", "items", "highlights", "items"),
  ("volunteer", "items", "summary"),
  ("volunteer", "items", "highlights", "items"),
  ("education", "items", "summary"),
  ("awards", "items", "summary"),
  ("certificates", "items", "summary"),
  ("publications", "items", "summary"),
  ("references", "items", "reference"),
  ("projects", "items", "summary"),
  ("projects", "items", "description"),
  ("projects", "items", "highlights", "items"),
).fold(
  schema-from-json-schema(strict-json),
  (schema, at) => schema-put(schema, at, markup()),
)

#let resume = parse(resume-schema-strict, path("resume.json"))
```
<!-- x-release-please-end -->

Typed extras (`additionalProperties` with a schema) still pass if they
match, and the free-form `custom` objects stay open. A misspelt key is
now reported with a suggestion:

```text
  - work[0].positon: unknown key "positon". Did you mean "position"?
```
