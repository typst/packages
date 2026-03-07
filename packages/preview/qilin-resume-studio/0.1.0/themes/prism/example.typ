#import "template.typ": blueprint

// ========================================
// 📄 prism 主题示例
// ========================================

#let data = yaml("example.yml")

#show: blueprint.with(data: data)