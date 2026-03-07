#import "template.typ": blueprint

// ========================================
// 📄 财务分析（蓝块主题）示例
// ========================================

#let data = yaml("example.yml")

#show: blueprint.with(data: data)
