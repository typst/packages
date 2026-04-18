= Bibliography

#bibliography(
  bytes((
      "/RES/lorem.bib",
      "/RES/glossary.bib",
    ).map(read).join("\n")
  ),
  style: "ieee",
  title: none,
)
