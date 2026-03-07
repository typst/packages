#import "template.typ": blueprint

// ========================================
// 📄 brilliant-cv 主题示例
// ========================================

#let data = yaml("example.yml")

#show: blueprint.with(data: data)