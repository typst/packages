// 网页各独立页的统一入口:make 传 --input 页=<路径>(相对 内容/,不含 .typ),
// 如 --input 页=概述。模板在这里套用,故 内容/ 下的正文保持"只管正文"的片段写法
// (不自己 #show),既能被 内容/index.typ 整份 #include,也能单独成一页。
// / Single entry for every standalone page: `make` passes the page path via
// --input 页=. The template is applied here, so chapters stay plain fragments
// that both the full entry and the per-page build can reuse.
#import "../配置.typ": *

#let 页 = sys.inputs.at("页", default: "")
#let 标题 = if 页 == "" { 页 } else { 页.split("/").last() }
// 正文源文件(相对项目根):make 传 --input 源=;缺省为 内容/<页>.typ,
// 目录页(如 内容/生物/index.typ → 页=生物)由 make 显式传入
#let 源 = sys.inputs.at("源", default: "内容/" + 页 + ".typ")

#show: 网页模板.with(页标题: 标题)

#include "../" + 源
