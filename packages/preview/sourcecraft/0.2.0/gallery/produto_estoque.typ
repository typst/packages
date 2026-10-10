#import "../src/lib.typ": source-diagram, setup-sourceuml
#set page(margin: 5pt, width: auto,height: auto)

#source-diagram(
  "class Produto {
  private String nome;
  private double preco;
  public String getNome() {}
}
class Estoque {
  private List<Produto> produtos;
  public Estoque() {
    produtos = new ArrayList<>();
  }
}",
  grammar: "java",
  max-height: 8cm,
)