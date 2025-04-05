// 导入
#import "/package/lib.typ": *
#import "/package/font.typ": *
#import "/package/util.typ": *
// // 自定义变量和样式
// #import "/template/用户设置.typ": *
// 拆分定义，更好理解
#import "/style/页面样式.typ": *
#import "/style/标题样式.typ": *
#import "/style/内容样式.typ": *
#import "/style/图形样式.typ": *
#import "/style/页眉页脚样式.typ": *

// 全局样式
#let global-style(doc) = {
  // 设置页面样式
  show: page-style
  // 设置标题样式
  show: heading-style.with(sans-serif: 黑体, h-size: 小四, h1-size: 三号, h2-size: 四号)
  // 设置内容样式
  show: content-style.with(serif: 宋体, sans-serif: 黑体, raw-font: 等宽, emph-font: 楷体, size: 小四)
  // 设置图形样式
  show: figure-style
  // 设置中文字符换行修复
  show: cjk-fix
  doc
}
