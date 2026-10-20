// # External elements. Elementos externos.
// NBR 14724:2024 4.1

// ## Cover. Capa.
// NBR 14724:2024 4.1.1

#import "../data/data.typ": address, authors, institution, organization, program, subtitle, title, volume_number, year
#import "../packages.typ": quati-abnt.academic_work.pages.include_cover

#include_cover(
  address: address,
  authors: authors,
  institution: institution,
  organization: organization,
  program: program,
  subtitle: subtitle,
  title: title,
  volume_number: volume_number,
  year: year,
)
