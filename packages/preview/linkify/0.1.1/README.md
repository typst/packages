# Typst Package: `linkify`

`linkify` is a Typst package that allows you to generate nicely-formatted links and URL strings to contents on different media platforms. It has two main sub-modules: the `linkify.url` sub-module which generates URL strings and the `linkify.display` submodule that allows you to insert a nicely-formatted clickable `link` element into your document.

The package also provides a few additional features that allows you to turn `link` elements that directly displays a URL into `raw` format, and perform conversions between Bilibili AVID and BVID.

The currently supported platforms include:

- Bilibili (videos, users)
- Wechat (gongzhonghao accounts and articles)
- Zhihu (column articles, questions, answers)
- Youtube (videos, channels)
- Wikipedia
- Moegirl Pedia
- Twitter (users, posts)
- Book ISBN search platforms

## Examples

* Apply the `url-as-raw` `show` rule to `link` elements. Display all URL `link`s in `raw` format.

    ```typst
    #import "@preview/linkify:0.1.0": url as ln,
    #import linkify.display: *

    #show: url-as-raw

    // URL all displayed as `raw` format, while still clickable

    #link("https://www.typst.app/docs") \
    #link("mailto:someone@example.com") \
    #link("tel:11451419198")

    // If display content is set otherwise, then it is not affected

    #link("https://www.typst.app/docs")[Typst Documentation]
    ```


* Creating links to contents.

    ```typst
    #import "@preview/linkify:0.1.0": url as lu, // abbreviation for `linkify.url`
    #import linkify.display: *

    // Bibibili

    #bili(11) \ // show as AVID or BVID depending on input
    #bili("14g4y1574R") \
    #bili(11, format: "bv") \  // specify to show as BVID
    #bili("14g4y1574R", format: "av", prefix: false) \ // no AV / BV prefix
    #bili(uid: 2) // user ID
    #bili(uid: 2, "⑨bishi") // username

    #link(lu.bili(11))[B 站最早的 MV] \ // string URL with customized text
    #link(lu.bili(uid: 2))[Founder of Bilibili]

    // Twitter / X

    #twitter("anime_oshinoko") \ // account
    #twitter("BTR_anime") \
    #link(
      lu.twitter("anime_oshinoko", 1663915842164146177),
      text(lang: "ja")[のらりくらり♪],
    ) // post (requires customized display content currently)

    // Moegirl Pedia

    #moegirl("鸡你太美") \
    #moegirl("二次元禁断综合征") \
    #moegirl("孤独摇滚！")

    // Wikipedia

    #wiki("Maslow's hiearchy of needs") \ // quotes shown as `smartquote`
    #wiki("Charles Baudelaire", lang: "fr") // language can be specified
    ```

## Change log

### 0.1.1

* Added support to link to a specific chapter for Wikipedia and MoeGirl links.
* `url-as-raw` can now be used as `show: url-as-raw`, no need to say `show link: url-as-raw` any more.

---

# Typst 包：`linkify`

`linkify` 是一个用于生成并在文中插入互联网内容平台链接的 Typst 包，其具有两个主要的子模块，分别是用于生成字符串链接的 `linkify.url` 子模块，和用于生成可插入文档的格式化 `link` 元素的 `linkify.display` 子模块。

此包还提供一些附加功能，包括可以将直接展示 URL 的 `link` 元素显示为 `raw` 样式，以及实现 B 站 AV 号和 BV 号的互相转换等。

此包目前已经收录的平台包括：

- B 站（视频、用户）
- 微信（公众号、公众号文章）
- 知乎（专栏文章、问题、答案）
- Youtube（视频、频道）
- 维基百科
- 萌娘百科
- 推特（用户、推文）
- 书籍 ISBN 号查询平台

## 使用例

* 对 `link` 元素应用 `url-as-raw` 的 `show` 规则，将所有直接以 URL 形式呈现的 `link` 元素，包括网址、邮箱地址和电话号码展示为 `raw` 格式。

    ```typst
    #import "@preview/linkify:0.1.0": url as ln,
    #import linkify.display: *

    #show link: url-as-raw

    // URL 全部显示为 `raw` 格式，但仍可点击

    #link("https://www.typst.app/docs") \
    #link("mailto:someone@example.com") \
    #link("tel:11451419198")

    // 若主动设置了显示文字，则不受影响，显示为正文字体

    #link("https://www.typst.app/docs")[Typst 帮助文档]
    ```


* 创建内容链接

    ```typst
    #import "@preview/linkify:0.1.0": url as lu, // `linkify.url` 的简写
    #import linkify.display: *

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
    ```

## 更新记录

### 0.1.1

* 维基百科和萌娘百科链接新增章节定位功能
* 应用 `url-as-raw` 规则现在可直接书写 `show: url-as-raw`, 无需再使用 `show link: url-as-raw`