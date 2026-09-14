// 14/02/2026
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema/site/bestiary/bestiary.json
// Possible `name` data entries are as follows:
//
// string

#import "../../utils.typ": call-if-fn

#let render-name(self, body) = [
  #assert(body.keys().contains("name")) 
  = #call-if-fn(self.title.style, body.name)
]
