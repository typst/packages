#import "template.typ": blueprint

// ========================================
// 📄 Tech Pro 主题示例
// ========================================

#let data = yaml("example.yml")

#show: blueprint.with(data: data)