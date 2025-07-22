#import "./src/lib.typ" as linkify
#import linkify.url as ln
#import linkify.display: *

#show link: url-as-raw

#link("mailto:someone@example.com")

#bili(11, format: "bv") \
#bili(1145, format: auto) \
#B站("14g4y1574R", format: "av", prefix: false)

#twitter("anime_oshinoko")\
#link(ln.twitter("anime_oshinoko", 1663915842164146177))

#isbn("978-7513342919", dash: false)

#萌百("鸡你太美") \
#moegirl("二次元禁断综合征") \
#moegirl("孤独摇滚！")

#wiki("Maslow's hiearchy of needs") \
#维基("Charles Baudelaire", lang: "fr")
