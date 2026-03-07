#import "template.typ": blueprint

// ========================================
// 📄 Avatar Pro 主题示例
// ========================================

#let data = yaml("example.yml")

#show: blueprint.with(data: data)
