# gairm-import reference

The [README](README.md) is the guide: quick start, input forms, errors,
null handling and the two resume schemas. This file covers the rest, and
says each thing once.

- [Constructors](#constructors)
- [Formats](#formats)
- [Lenses and edits](#lenses-and-edits)
- [Introspection](#introspection)
- [JSON Pointer](#json-pointer)
- [JSON Schema translation](#json-schema-translation)
  - [Supported keywords](#supported-keywords)
  - [Out of scope](#out-of-scope)
  - [Deviations from draft 7](#deviations-from-draft-7)
- [Deprecated names](#deprecated-names)

The examples assume the whole package is imported:

<!-- x-release-please-start-version -->
```typst
#import "@preview/gairm-import:0.12.0": *
```
<!-- x-release-please-end -->

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
| `number(..)` | `minimum`, `maximum`, `exclusive-minimum`, `exclusive-maximum`, `multiple-of` | an int or a float |
| `integer(..)` | the same as `number` | a number with no fractional part (`1.0` passes, `1.5` fails) |
| `array-of(elem, ..)` | `min-items`, `max-items`, `unique-items` | an array whose every item matches `elem` |
| `object(shape, ..)` | `required-keys`, `dependent-required`, `additional` | a dictionary with the fields in `shape` |
| `map(value-schema, ..)` | `required-keys` | a dictionary with any keys, every value matching `value-schema` |
| `any-of(a, b, …)` | | a value matching at least one member |
| `one-of(a, b, …)` | | a value matching exactly one member |
| `not-of(member)` | | a value that does not match `member` |
| `if-of(cond, ..)` | `then`, `otherwise` | a value that matches `then` if it matches `cond`, and `otherwise` if not |
| `nullable(member)` | | `null` or a value `member` accepts (see [Null handling](README.md#null-handling)) |
| `enum-of(values)` | | one of `values`, which may mix types |
| `const-of(value)` | | `value` only; the same as `enum-of((value,))` |

- `min-length` and `max-length` count characters as grapheme clusters.
- `format` takes one of the nine names under [Formats](#formats).
- `pattern` takes a `regex` or a pattern string; `expected` says what a
  match looks like, for the error message (default `"matching pattern"`),
  and is only allowed with a `pattern`. With a `format` as well, the
  string must have the format and match the pattern.
- `any-of` and `one-of` take their members as separate arguments or as one
  array: `any-of(a, b)` equals `any-of((a, b))`.
- `if-of` is JSON Schema's `if` / `then` / `else`, with the else branch
  named `otherwise` (`else` is a Typst keyword). It takes `then`,
  `otherwise` or both; a branch left out accepts the value as it is. Only
  whether the value matches `cond` counts: `cond`'s errors are never
  reported, and the branch it picks gives the errors and the model.
  `if-of(string(min-length: 5), then: string(pattern: "^x"))` accepts
  `"abc"` and `"xyzzy"`, and rejects `"abcde"`.
- `object`'s `additional` says what to do with keys not in `shape`:
  `none` (the default) or `false` rejects them, `true` lets them through
  unchecked, and a schema checks each one against it. `required-keys` lists
  the keys that must be present, and `dependent-required` maps a key to the
  keys that must be present whenever it is. A key holding `null` counts as
  absent for both unless `strict-null` is on.

Four kinds take no arguments and are constants: `content-type` (a string,
returned as Typst `content` so it splices into markup), `bool-type`,
`null-type` (`null` or an absent key) and `any-type` (any value, passed
through unchanged).

```typst
#let member = object(
  (
    name: string(min-length: 1, max-length: 80),
    email: string(format: "email"),
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

## Formats

`string(format: …)` gates a string with a regex. The checks are
deliberately permissive: they reject obvious malformations without
claiming full RFC compliance.

| `format` | Accepts | Error hint |
|---|---|---|
| `date` | `YYYY`, `YYYY-MM` or `YYYY-MM-DD`, month and day in range | `an ISO-8601 date (e.g. "2024-01-15")` |
| `date-time` | `YYYY-MM-DDTHH:MM:SS`, optional fraction and `Z` / `±HH:MM` offset | `an ISO-8601 datetime (e.g. "2024-01-15T10:00:00Z")` |
| `time` | `HH:MM:SS`, optional fraction and `Z` / `±HH:MM` offset | `an ISO-8601 time (e.g. "10:00:00Z")` |
| `uri` | any scheme, `:`, then no whitespace (`https://…`, `mailto:…`, `urn:…`) | `a URI (e.g. "https://example.com")` |
| `email` | a local part (or a quoted one), `@`, a domain of one or more labels or an address literal (`name@[127.0.0.1]`) | `an email (e.g. "name@example.com")` |
| `uuid` | 8-4-4-4-12 hex digits, any case | `a UUID (e.g. "123e4567-e89b-12d3-a456-426614174000")` |
| `hostname` | dot-separated labels of letters, digits and inner hyphens | `a hostname (e.g. "example.com")` |
| `ipv4` | a dotted quad, octets 0-255, no leading zeros | `an IPv4 address (e.g. "192.0.2.1")` |
| `ipv6` | hex groups with `::` compression; no embedded-IPv4 tail | `an IPv6 address (e.g. "2001:db8::1")` |

As in RFC 3339, `date-time` and `time` take `T` and `Z` in either case and
a leap second (`23:59:60Z`: second 60 at minute 59, or at any minute under
an offset with minutes).

A miss reports `expected <hint>.` at the field's path. Under
`resume-schema-strict`:

```text
basics.email:           expected an email (e.g. "name@example.com").
basics.url:             expected a URI (e.g. "https://example.com").
certificates[0].date:   expected an ISO-8601 date (e.g. "2024-01-15").
```

Data written in Typst can give a `date` field a `datetime` with a date and
no time, and a `date-time` field one with both; it is checked and returned
as the ISO string (`"2024-01-05"`, `"2024-01-05T09:03:07"`). A `datetime`
of the other shape is rejected rather than truncated. Otherwise coercion is
pass-through: a formatted value reaches the model as the same string.

A `pattern` is a Typst regex, and matches anywhere in the string: anchor it
with `^…$` for a full-string match.

## Lenses and edits

A *location* names one node in a schema: a path array, or `(lens: path)`.
Every function below takes either. A path's segments are:

| Segment | Enters |
|---|---|
| a field name (`"basics"`) | that field of an object |
| `"items"` | an array's item schema |
| `"additionalProperties"` | an object's `additional` schema (only when it is a schema, not `true`) |
| an int (`0`) | that member of an `any-of` or `one-of` |
| `"not"` | a `not-of` member |
| `"if"`, `"then"`, `"else"` | an `if-of`'s condition, or a branch it has (`"else"` is `otherwise`) |

`()` is the whole schema. A field literally named `"additionalProperties"`
wins over the keyword; reach the additional schema in that case with
`lens-over` on the parent. Paths join with `+`.

| Function | Returns |
|---|---|
| `lens-get(schema, at)` | the node at `at` |
| `lens-put(schema, at, value)` | the schema with the node at `at` replaced by `value` |
| `lens-over(schema, at, fn)` | the schema with the node at `at` replaced by `fn(node)` |
| `add-field(schema, at, name, field, required: false)` | the object at `at` with a new field, required if `required: true` |
| `remove-field(schema, at, name)` | the object at `at` without the field, and without it in `required-keys` and `dependent-required` |
| `set-required(schema, at, keys)` | the object at `at` requiring exactly `keys` |
| `unset-required(schema, at, keys)` | the object at `at` no longer requiring `keys` |

Every edit returns a new schema and leaves its input alone. The schema
comes first, so edits chain through `.fold`. A node written by `lens-put`
or returned by `lens-over`'s function must be a schema, and every object
an edit touches is rebuilt through `object()`, so an edit cannot break its
invariants. A missing path, a missing field, or adding a field that exists
panics.

```typst
// A renderer-specific top-level field.
#let altacv-schema = add-field(
  resume-schema, (), "focusAreas", array-of(content-type),
)

// A numeric rating on every language entry.
#let with-rating = add-field(
  resume-schema, ("languages", "items"), "rating", number(),
)

// Back to a plain-string summary in the strict schema.
#let plain-summary = lens-put(
  resume-schema-strict, ("basics", "summary"), string(),
)

// Spreading `meta` keeps its `additional` and `required-keys`.
#let with-extra-meta = lens-over(
  resume-schema,
  ("meta",),
  meta => (..meta, shape: (..meta.shape, source: string())),
)

// Require basics.name and basics.email, then relax email again.
#let strict-basics = set-required(resume-schema, ("basics",), ("name", "email"))
#let name-only = unset-required(strict-basics, ("basics",), ("email",))
```

`add-field` keeps everything else about the object, including upstream's
`additionalProperties: true`. Splicing the shape into a new object,
`object((..resume-schema.shape, focusAreas: …))`, does not: `object()`
rejects undeclared keys by default, so it silently closes the top level.

Folding `paths-of-kind` into `lens-put` edits every node of a kind at once,
and covers fields a future schema adds:

```typst
#let corporate-uri = string(
  pattern: "^https://(corp|docs)\.example\.com/",
  expected: "a corporate URL",
)
#let corporate-schema = paths-of-kind(resume-schema, string(format: "uri")).fold(
  resume-schema,
  (schema, path) => lens-put(schema, path, corporate-uri),
)
```

## Introspection

`describe-schema(schema)` draws a schema as an indented tree, one line per
field with its kind:

- keys sort alphabetically, so diffs across schema versions stay stable;
- a required field is suffixed `*`, an array `[]`, and `*` as a key stands
  for any other key (the `additional` schema);
- constraints follow the kind in brackets, a format in parentheses, and a
  pattern as `+ pattern`;
- a union lists its members as `[0]`, `[1]`, … under `any of:` or
  `one of:`, `nullable(X)` draws as `X?`, a `not-of` member shows as
  `not`, and an `if-of`'s condition and branches as `if`, `then` and
  `else`;
- an object's `dependent-required` entries close its block as
  `trigger → dependents`.

For `member` from [Constructors](#constructors):

```text
age     integer (minimum 0)
code    string + pattern
email*  string (email)
name*   string (min-length 1, max-length 80)
phone   string
rating  number (minimum 0, maximum 5, multiple-of 0.5)
tags[]  string (min-items 1, unique-items)
phone → email
```

An excerpt of `describe-schema(resume-schema-strict)`:

```text
basics:
  …
  email     string (email)
  …
  name      string
  …
  summary   content
  url       string (uri)
…
meta:
  canonical     string (uri)
  lastModified  any of:
    [0]  string (date-time)
    [1]  string (date)
  version       string
…
work[]:
  …
  highlights[]  content
  keywords[]    string
  location      one of:
    [0]  string
    [1]:
      address      string
      …
```

A conditional, `if-of(string(min-length: 5), then: string(pattern: "^x"),
otherwise: number())`:

```text
if    string (min-length 5)
then  string + pattern
else  number
```

`paths-of-kind(schema, query)` lists the path of every node matching
`query`, inside union, `not-of` and `if-of` members too, sorted as above.
The paths use the segments under [Lenses and edits](#lenses-and-edits), so
they work wherever a location does. A query is:

- a schema node, which matches the nodes of its kind that have every field
  the query sets, with the same value: `string()` finds every string,
  `string(format: "date")` only the date strings, `number()` numbers but
  not integers, and `number(minimum: 0)` only numbers with that minimum;
- or a constructor, which matches every node of the kind it builds:
  `enum-of`, `any-of`, `one-of`, `not-of`, `if-of`.

`object` and `array` are walked through, not searched for, and panic as a
query.

```typst
#paths-of-kind(resume-schema-strict, string(format: "date"))
// → (("awards", "items", "date"), …, ("meta", "lastModified", 1), …)
#paths-of-kind(member, number())
// → (("rating",),)
#lens-get(resume-schema-strict, ("meta", "lastModified", 0)).kind
// → "string"
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
JSON Pointer tool can resolve against the document. A lens or
`paths-of-kind` path addresses the **schema**, in this package's own
segments, and encodes segment for segment: `("basics", "email")` becomes
`/basics/email` and `("work", "items")` becomes `/work/items`. That is
neither a data pointer nor a JSON Schema location, which would read
`/properties/work/items`.

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
draft 7, and panics, naming the keyword, on anything it would otherwise
have to drop.

```typst
#let canonical = schema-from-json-schema(path("resume-schema.json"))
#let model = coerce(json("resume.json"), schema: canonical)
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
  only) is `any-type`. With type-specific keywords (`{minLength: 2}`) it is
  an `any-of` over boolean, object, array, number, string and null, each
  keyword narrowing only its own type's member; the object member is open
  unless the node has `properties` or `additionalProperties`.
- Strings: `minLength`, `maxLength`, `pattern`, and `format` (the nine
  under [Formats](#formats)). With both `format` and `pattern`, both
  apply.
- Numbers: `minimum`, `maximum`, `exclusiveMinimum`, `exclusiveMaximum`
  (as numbers, draft 7's form), `multipleOf`.
- Arrays: `items` (a single schema; no `items` takes any item),
  `minItems`, `maxItems`, `uniqueItems`.
- Objects: `properties`, `required`, `additionalProperties` (a schema,
  `true` or `false`), `dependentRequired`, and draft 7's array form of
  `dependencies`, which means the same.
- `enum` and `const` become `enum-of` and `const-of`. `type` and
  constraint keywords beside them are folded in at translate time: only
  the values that satisfy them are kept, and a keyword leaves values of
  other types alone (`minimum` ignores a string).
- `anyOf`, `oneOf` and `not` become `any-of`, `one-of` and `not-of`.
- `allOf` of object schemas is merged at translate time: the properties
  and `required` lists union, a key in two members must have the same
  schema, `additionalProperties` must agree (a member without it counts as
  closed), and members that are closed or typed must declare the same
  properties. A `type: ["object", "null"]` member merges as its object;
  the result is nullable only if every member is.
- `if`, `then` and `else` become `if-of`. With no other keywords on the
  node, the branches are `then` and `else` as written, of any kind. Beside
  other keywords, each branch is the `allOf` of those keywords and the
  branch, merged as above, and a missing branch is those keywords alone:
  the node and each branch must be object schemas. A branch takes the
  node's `type`, and, unless it sets `additionalProperties`, the node's
  `properties` and `additionalProperties`, so `then: {required: ["b"]}`
  requires a property the node declares. `if` is only a test, so every
  object in it without `additionalProperties` is open, as draft 7 reads
  it. `if` with neither `then` nor `else` checks nothing and is dropped.
- `$ref` to a fragment in the same document (`#/definitions/…`,
  `#/$defs/…`), percent-decoded and then read as a JSON Pointer, so a
  numeric segment can index an array (`#/definitions/pair/anyOf/0`).
- Annotations, accepted and ignored: `$schema`, `$id`, `$comment`,
  `title`, `description`, `default`, `examples`, `readOnly`, `writeOnly`,
  `deprecated`, `definitions`, `$defs`.

`minLength`, `maxLength`, `minItems` and `maxItems` take a non-negative
integer; a whole-number float (`2.0`) counts.

### Out of scope

Each of these panics with a message naming it:

- `dependentSchemas`, and the schema form of `dependencies`;
- `additionalItems`, `contains`, `minProperties`, `maxProperties`,
  `patternProperties`, `propertyNames`, `contentMediaType`,
  `contentEncoding`, and any keyword not listed above, a misspelling like
  `minLenght` included;
- boolean schemas (`properties: {a: true}`, `items: false`) and the array
  form of `items`;
- `$ref` outside the document, to the root (`#` or `#/`), to a named
  anchor, or in a cycle;
- formats other than the nine;
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
- `null` as a keyword's value (`type: null`), except in an annotation and
  `const: null`.

An invalid regex in `pattern` fails with Typst's own regex error, which
the translator cannot catch.

### Deviations from draft 7

Where a draft 7 validator and this package disagree on the same schema:

- **`null` is absent by default.** A key holding `null` is treated as
  missing and dropped from the model, and a `null` array item is dropped,
  instead of being checked as a value. `strict-null: true` restores draft
  7's reading. A document that is `null` panics in both modes.
- **A missing `additionalProperties` is closed.** Draft 7 lets undeclared
  keys through unless `additionalProperties` says otherwise; here they are
  rejected unless it is `true` or a schema. `type: "object"` with neither
  `properties` nor `additionalProperties` panics, and an `allOf` member
  without `additionalProperties` counts as closed (except inside `if`;
  see the translation).
- **Unknown keywords panic.** Draft 7 ignores a keyword it does not know;
  here it panics, so a typo cannot silently drop a constraint. So does a
  keyword that applies to none of a node's `type`s, and one whose value is
  `null`.
- **Unknown formats panic, and known ones are asserted.** Draft 7 treats
  `format` as an annotation that a validator may check; here the nine
  formats are always checked, with permissive regexes rather than full RFC
  grammars, and any other format panics.
- **`pattern` is a Typst regex**, not ECMA-262: there is no look-around and
  no backreference, and `\d` and `\w` match Unicode digits and letters.
- **String length counts grapheme clusters**, not code points: `"é"`
  written as `e` plus a combining accent has length 1.
- **`multipleOf` on floats uses a tolerance** (a ratio within 1e-9 of a
  whole number), so `0.3` is a multiple of `0.1`.
- **`uniqueItems` compares items as the model holds them**: by default a
  null key is dropped, so under an object schema `{"a": 1, "b": null}` and
  `{"a": 1}` are duplicates. A free-form object (`additionalProperties:
  true` and nothing declared) keeps its nulls, so there they differ.
- **`integer`** accepts `1.0`, as draft 7 does, and the model keeps it as
  the float `1.0`.
- **`$id` is ignored**: it sets no base URI, so `$ref` resolves against
  the document root only. External, root, anchor and recursive `$ref`s
  panic.
- **`$ref` and the composition keywords stand alone.** Draft 7 ignores a
  `$ref`'s siblings and applies a composition keyword's siblings as well;
  here a sibling that is not an annotation panics. `if` / `then` / `else`
  take plain siblings (below), but not a `$ref` or a composition keyword.
- **`allOf`, and `if` / `then` / `else` beside other keywords, are merged
  at translate time**, so only object members are supported, members that
  are closed or typed must declare the same properties, and a branch
  cannot narrow a property its node already declares. Alone on a node, the
  branches may be any schema.
- **`then` and `else` without `if` panic**; draft 7 ignores them.
- **`enum` and `const` are folded with their siblings** at translate time;
  an `enum` that no value survives panics instead of rejecting every
  value.
- **Boolean schemas and the array form of `items` are not supported**,
  except `additionalProperties: true` / `false`.
- **`dependentRequired`**, from draft 2019-09, is accepted alongside draft
  7's array-form `dependencies`.

## Deprecated names

Each of these still works and will be removed in 1.0.

| Deprecated | Use instead |
|---|---|
| `str-type`, `number-type`, `integer-type` | `string()`, `number()`, `integer()` |
| `date-string`, `datetime-string`, `uri-string`, `email-string`, `uuid-string`, `hostname-string`, `ipv4-string`, `ipv6-string`, `time-string` | `string(format: "date")`, `"date-time"`, `"uri"`, `"email"`, `"uuid"`, `"hostname"`, `"ipv4"`, `"ipv6"`, `"time"` |
| `pattern-string(re, expected: e)` | `string(pattern: re, expected: e)` |
| `lens(path)` | the path, or `(lens: path)` |
| `lens-then(a, b)` | `a + b` on the paths |
| `kind-at(schema, at)` | `lens-get(schema, at).kind` |
| `lens-get(at, schema)`, `lens-put(at, schema, v)`, `lens-over(at, schema, fn)` | the schema first |
| `(kind: "lens", path: p)` | `p` or `(lens: p)` |
| a kind name string in `paths-of-kind` (`"date-string"`) | a node or constructor (`string(format: "date")`) |
| hand-built `(kind: "str")`, `(kind: "pattern-string")`, `(kind: "date-string")` … | `(kind: "string")`, with a `pattern` or `format` field |

Arguments are told apart by type, so an old call works unchanged. As a
`paths-of-kind` query, `pattern-string` finds every string with a pattern.
