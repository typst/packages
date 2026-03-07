#import "template.typ": blueprint

// ========================================
// 📄 现代主题示例
// ========================================

#let data = yaml("example.yml")

#show: blueprint.with(data: data)
