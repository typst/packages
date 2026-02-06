#import "/src/components/fullname-with-title-component.typ": fullname-with-title-component
#import "/src/components/orcid-with-prefix-component.typ": orcid-with-prefix-component

// Danışmanın ünvanı, adı ve soyadını ve bunun altına da yeni bir satıra ORCID numarasını ekler. [Adds the title, first name, and last name of the advisor, and then adds the ORCID number below them.]\
/* [Örnek]:\
  [Öğretim Üyesi Ünvanı] [Adı SOYADI]\n[ORCID N]
*/
#let advisor-with-orcid-component(
  advisor: none,
) = {
  // Danışman ünvanı, adı ve soyadını ekle. [Add the advisor's title, first name, and last name.]
  fullname-with-title-component(
    title: advisor.academic-member-title,
    first-name: advisor.first-name,
    last-name: advisor.last-name,
  )

  // Satır sonu ekle. [Add line break.]
  linebreak()

  // Danışman ORCID numarasını ekle. [Add the advisor's ORCID number.]
  orcid-with-prefix-component(orcid: advisor.orcid)
}
