#import "utils.typ": check-keys

#let check-author-info(author-info) = {
  let expected-keys = ("name", "group-name", "school-name")
  check-keys("check-author-info", expected-keys, author-info)
}
