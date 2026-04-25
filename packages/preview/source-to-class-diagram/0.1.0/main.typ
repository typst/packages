#import #import "@preview/source-to-class-diagram:0.1.0": setup-classuml

#show: setup-classuml

#set page(paper: "a4")
#set text(font: "Segoe UI")

= source-to-class-diagram — Demonstração

== Exemplo 1: Sintaxe Java

```class-diagram-java
@Layout(level=3, order=1)
class ExceptionType{

}
@Layout(level=2, order=0)
interface Interface1{
 void method1();
}

@Layout(level=2, order=1)
class MiniTeste implements Interface1{
  public void method1(){
    throw new ExceptionType()
  }

  private void method2(){

  }
}

class Class1 {
  private List<Class2> listClass2;
  public addClass2(String class2Name){
    Class2 class2 = new Class2(class2Name, this);
    listClass2.add(class2);
  }
}

class Class2{
  private Class1 class1;
  private String name;

  public Class2(String name, Class1 class1){
    this.class1 = class1;
    this.name = name;
  }

  public Class2(Class1 class1){
    this.class1 = class1;
  }
}
class Class4 extends Class1{
  public String teste;
}

@Layout(level=1, order=1)
class Class3 implements Interface1{
  private Class1 class1;
}

class Class4 extends Class1{
  public String teste;
}

class Class5 extends Class1{
  public String teste;
}

class Class6 extends Class1{
  public String teste;
}

@Layout(level=3, order=0)
enum Porte {
  PEQUENO,
  MEDIO,
  GRANDE
}
```

== Exemplo 2: Sintaxe CSharp

```class-diagram-csharp
public abstract class Animal {
  private string nome;
  private int idade;
  public string GetNome() {}
  public abstract void EmitirSom();
}
public class Cachorro : Animal {
  private string raca;
  public void Latir() {}
}
public interface IAlimentavel {
  void Alimentar();
}
public class Gato : Animal, IAlimentavel {
  private bool domestico;
  public void Miar() {}
}
```
