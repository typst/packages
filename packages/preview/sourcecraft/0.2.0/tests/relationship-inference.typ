#import "../src/grammars/java.typ" as java
#import "../src/grammars/csharp.typ" as csharp

#let java-diagram = java.parse(
  "class Service {\n  Customer customer;\n  void importData(Map<String, Customer> customers) {}\n  void nested(Map<String, List<Order>> values) {}\n  void compare(Pair<Customer, Order> pair) {}\n}\n"
)

#assert(java-diagram.relations.any(
  relation => relation.type == "association" and relation.to == "Customer"
))
#assert(java-diagram.relations.any(
  relation => relation.type == "dependency" and relation.to == "Order"
))
#assert(not java-diagram.relations.any(
  relation => relation.to == "String"
))
#assert(not java-diagram.relations.any(
  relation => relation.to == "Customer>"
))
#assert(not java-diagram.relations.any(
  relation => relation.to == "List"
))
#assert(java-diagram.relations.filter(
  relation => relation.to == "Customer"
).len() == 1)

#let java-constructor-diagram = java.parse(
  "class Service {\n  Customer customer;\n  Service(Map<String, Customer> customers) {}\n}\n"
)
#assert(java-constructor-diagram.relations.any(
  relation => relation.type == "aggregation" and relation.to == "Customer"
))

#let csharp-diagram = csharp.parse(
  "class Service {\n  void importData(Dictionary<string, Customer> customers) {}\n  void nested(Dictionary<string, List<Order>> values) {}\n  void compare(Pair<Customer, Order> pair) {}\n  void use(ref Customer customer) {}\n}\n"
)

#assert(csharp-diagram.relations.any(
  relation => relation.type == "dependency" and relation.to == "Customer"
))
#assert(csharp-diagram.relations.any(
  relation => relation.type == "dependency" and relation.to == "Order"
))
#assert(not csharp-diagram.relations.any(
  relation => relation.to == "string"
))
#assert(not csharp-diagram.relations.any(
  relation => relation.to == "Customer>"
))
#assert(not csharp-diagram.relations.any(
  relation => relation.to == "List"
))

#let csharp-constructor-diagram = csharp.parse(
  "class Service {\n  Customer customer;\n  Service(Dictionary<string, Customer> customers) {}\n}\n"
)
#assert(csharp-constructor-diagram.relations.any(
  relation => relation.type == "aggregation" and relation.to == "Customer"
))

#text("Relationship inference regression tests passed.")
