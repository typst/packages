#import "./src/lib.typ" as linkify: url as lu, // `linkify.url` 的简写
#import linkify.display: *

#show link: url-as-raw

// URL 全部显示为 `raw` 格式，但仍可点击

#link("https://www.typst.app/docs") \
#link("mailto:someone@example.com") \
#link("tel:11451419198")

// 若主动设置了显示文字，则不受影响，显示为正文字体

#link("https://www.typst.app/docs")[Typst 帮助文档]

// B 站

#bili(11) \ // 根据输入自动显示为 AV 号或 BV 号
#bili("14g4y1574R") \
#bili(11, format: "bv") \  // 指定显示为 BV 号
#bili("14g4y1574R", format: "av", prefix: false) \ // 不加 `AV` / `BV` 前缀
#bili(uid: 2) // 用户 ID
#bili(uid: 2, "碧诗") // 用户名

#link(lu.bili(11))[B 站最早的 MV] \ // 生成字符串 URL，自定义显示文本
#link(lu.bili(uid: 2))[B 站站长]

// 推特

#twitter("anime_oshinoko") \ // 账号
#twitter("BTR_anime") \
#link(
  lu.twitter("anime_oshinoko", 1663915842164146177),
  text(lang: "ja")[のらりくらり♪],
) // 推文，尚不支持直接显示，需自定义显示文本

// 萌娘百科

#moegirl("鸡你太美") \
#moegirl("二次元禁断综合征") \
#moegirl("孤独摇滚！")

// 维基百科

#wiki("Maslow's hiearchy of needs") \ // 引号显示时自动转化为 `smartquote`
#wiki("Charles Baudelaire", lang: "fr") // 可指定条目语言