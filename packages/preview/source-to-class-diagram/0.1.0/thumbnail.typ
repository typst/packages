#import "src/lib.typ": setup-classuml

#set page(paper: "a4")

#show: setup-classuml


= Teste Gramática: Java

````typ
```class-diagram-java
class Departamento{
  private String nome;
  private String codigo;
  public Departamento(String nome, String codigo) {
    this.nome = nome;
    this.codigo = codigo;
  }
  public String getNome() {}
  public String getCodigo() {}
}
class Produto{
  private Departamento departamento;
  private String nome;
  private double preco;
  public Produto(Departamento departamento, String nome, double preco) {
    this.departamento = departamento;
    this.nome = nome;
    this.preco = preco;
  }
  public String getNome() {}
  public String getPreco() {}
  public Departamento getDepartamento() {}
  public void setPreco(double preco) {}
}
```
````

```class-diagram-java
class Departamento{
  private String nome;
  private String codigo;
  public Departamento(String nome, String codigo) {
    this.nome = nome;
    this.codigo = codigo;
  }
  public String getNome() {}
  public String getCodigo() {}
}
class Produto{
  private Departamento departamento;
  private String nome;
  private double preco;
  public Produto(Departamento departamento, String nome, double preco) {
    this.departamento = departamento;
    this.nome = nome;
    this.preco = preco;
  }
  public String getNome() {}
  public String getPreco() {}
  public Departamento getDepartamento() {}
  public void setPreco(double preco) {}
}
```
