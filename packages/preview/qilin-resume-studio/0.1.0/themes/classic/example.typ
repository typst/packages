#import "template.typ": blueprint

// ========================================
// 📄 经典主题示例
// ========================================

#let data = yaml("example.yml")

#show: blueprint.with(data: data)
