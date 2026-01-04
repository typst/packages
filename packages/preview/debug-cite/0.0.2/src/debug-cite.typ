#import "spec.typ"

#let match-types(types) = (
  ```xml
  <text value='"type": ['/>
  <group delimiter=", ">
    [[inner]]
  </group>
  <text value="], "/>
  ```
    .text
    .replace(
      "[[inner]]",
      {
        let template = ```xml
        <choose><if type="[[type]]">
          <text value="[[type]]" prefix='"' suffix='"' />
        </if></choose>
        ```.text
        types.map(t => template.replace("[[type]]", t)).join()
      },
    )
)

/// `tag` can be `"text" | "date" | "names"`.
#let match-vars(group, variables, tag: "text", suffix: " }, ") = {
  assert(("text", "date", "names").contains(tag))

  ```xml
  <text value='"[[group]]": { '/>
  <group delimiter=", ">
    [[inner]]
  </group>
  <text value='[[suffix]]'/>
  ```
    .text
    .replace("[[group]]", group)
    .replace("[[suffix]]", suffix)
    .replace(
      "[[inner]]",
      variables
        .map(v => (
          if tag == "date" {
            ```xml
            <date variable="[[v]]" form="numeric" prefix='"[[v]]": "' suffix='"' />
            ```.text
          } else {
            ```xml
            <TAG variable="[[v]]" prefix='"[[v]]": "' suffix='"' />
            ```
              .text
              .replace("TAG", tag)
          }
        ).replace("[[v]]", v))
        .join(),
    )
}


#let build-csl(extra: (:)) = (
  ```xml
  <?xml version='1.0' encoding='utf-8'?>
  <style xmlns="http://purl.org/net/xbiblio/csl" class="in-text" version="1.0">
    <info>
      <title>debug-cite</title>
      <id>https://typst.app/universe/package/debug-cite</id>
    </info>
    <macro name="debug">
      <group prefix="{ " suffix=" }">
        [[inner]]
      </group>
    </macro>
    <citation>
      <layout>
        <text macro="debug" />
      </layout>
    </citation>
    <bibliography>
      <layout>
        <text value="This CSL style is only intended for citations, not bibliography." />
      </layout>
    </bibliography>
  </style>
  ```
    .text
    .replace("[[inner]]", {
      match-types(spec.types)

      /// A list of `(group, tag, vars)` tuples, where `vars` is always nonempty
      let groups = (
        ("non-number-standard-variable", "text", spec.non-number-standard-variables),
        ("number-standard-variable", "text", spec.number-standard-variables),
        ("date-variable", "date", spec.date-variables),
        ("name-variable", "names", spec.name-variables),
        ("extra-text-variable", "text", extra.vars),
        ("extra-date-variable", "date", extra.dates),
        ("extra-name-variable", "names", extra.names),
      ).filter(((_group, _tag, vars)) => vars.len() > 0)

      for (i, (group, tag, vars)) in groups.enumerate() {
        // JSON does not allow trailing commas, so we need to treat the last group differently
        let last = i == groups.len() - 1

        if not last {
          match-vars(group, vars, tag: tag)
        } else {
          match-vars(group, vars, tag: tag, suffix: "} ")
          // The space after `}` is intentional. Typst has a special design/bug for the trailing suffix.
          // https://github.com/typst/hayagriva/issues/411
        }
      }
    })
)

#let debug-cite(
  key,
  /// Whether to display the result as a highlighted Typst dictionary.
  ///
  /// This feature depends on fragile JSON parsing.
  /// You can disable it if you meet `failed to parse JSON` error.
  pretty-print: true,
  /// List of extra variables to be inspected.
  ///
  /// In Typst 0.14, these arguments are useless.
  /// Most non-standard variables (e.g., CSTR) will lead to `error: failed to load CSL style`, and others are aliases of standard variables (e.g., editortranslator is an alias of editor-translator).
  /// Therefore, no new information can be obtained.
  extra-vars: (),
  extra-dates: (),
  extra-names: (),
  /// `__internal-formatter` is a function that receives the result dictionary and generates the content to be displayed.
  /// It is for HTML testing, and not meant to be used by regular end users.
  __internal-formatter: x => x,
  /// Additional arguments passed to the `cite` function.
  ..args,
) = {
  show: body => if pretty-print {
    // Convert the URL to plain text
    show link: it => it.body
    // Parse as JSON
    show regex(".+"): it => __internal-formatter(json(bytes(it.text)))
    body
  } else {
    body
  }

  cite(
    key,
    style: bytes(build-csl(extra: (
      vars: extra-vars,
      dates: extra-dates,
      names: extra-names,
    ))),
    ..args,
  )
}
