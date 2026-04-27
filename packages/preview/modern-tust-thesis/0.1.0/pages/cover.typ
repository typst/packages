#import "../utils/style.typ": zihao, ziti
#import "cover-bachelor.typ": cover-bachelor-page

#let cover-page(
  doctype: "bachelor",
  twoside: false,
  anonymous: false,
  info: (:),
  date: datetime.today(),
  key-to-zh: (:),
) = {
  cover-bachelor-page(
    twoside: twoside,
    anonymous: anonymous,
    info: info,
    date: date,
    key-to-zh: key-to-zh,
  )
}
