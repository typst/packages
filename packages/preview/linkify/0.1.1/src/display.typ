/// Generate nicely formatted, clickable links to media contents that can be directly inserted into articles. The media contents are mostly displayed by their content IDs. For example:
///
/// - The video BVID or AVID in monospaced font is used for Bilibili videos.
/// - Bilibili or Twitter (X) usernames are displayed in monospaced font preceded by an `@` symbol.
/// - Wikipedia and Moegirl Pedia's entries are displayed as their entry titles in formatted text.
///
/// If you want to customize the display content instead of using the default content ID, you can use the `linkify.url` sub-libray to generate string URLs and put it in a `link` element with custom content instead.
///
///
/// 为互联网内容平台的内容生成格式化的超链接。在大部分的情况下，链接文本会显示为对应平台的内容 ID, 例如：
///
/// - B 站视频以等宽字体显示为 BVID 或 AVID.
/// - B 站、推特 (X) 用户显示为以 `@` 开头的用户名。
/// - 维基百科和萌娘百科的条目以常规文本字体显示为格式化的条目名。
///
/// 如果希望自定义显示内容，而不是使用默认的内容 ID, 可以使用 `linkify.url` 子模块生成字符串链接，结合 `link` 元素显示自定义内容。

#import "_impl/display.typ": (
  url-as-raw,
  bili,
  weixin,
  youtube,
  wiki,
  moegirl,
  twitter,
  isbn,
)

#let B站 = bili
#let 微信 = weixin
#let 油管 = youtube
#let 维基 = wiki
#let 萌百 = moegirl
#let 推特 = twitter
#let X = twitter

