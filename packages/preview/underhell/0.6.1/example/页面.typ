// 独立页统一入口:--input 页=<路径>(相对 内容/,不含 .typ)。
// 源文件缺省取 内容/<页>.typ;目录页由构建脚本显式传 --input 源=
// (Typst 读不到文件系统,故回退需外部指定)。
//   cd example
//   typst compile --features html --input web=true 内容/index.typ out.html
//   typst compile --features html --input web=true --input 页=生物/怪动植物 页面.typ out.html
//   typst compile --features html --input web=true --input 页=生物 --input 源=内容/生物/index.typ 页面.typ out.html
// / Single entry for standalone pages: --input 页=<path relative to 内容/>.
#import "内容/配置.typ": *

#let 页 = sys.inputs.at("页", default: "")
#let 标题 = if 页 == "" { 页 } else { 页.split("/").last() }
#let 源 = sys.inputs.at("源", default: "内容/" + 页 + ".typ")

#show: 网页模板.with(页标题: 标题)

#include 源
