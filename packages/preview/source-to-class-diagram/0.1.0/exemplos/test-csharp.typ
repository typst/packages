#import "../src/lib.typ": setup-classuml

#set page(paper: "a4", flipped: true)
//#set page(width: auto)
//#set page(width: 10cm)
#show: setup-classuml


= Teste Gramática: Csharp

```class-diagram-csharp

public enum Porte
{
    Pequeno,
    Medio,
    Grande
}


public interface IInterface1
{
    void Method1();
}

public class MiniTeste : IInterface1
{
    public void Method1()
    {
        // Implementação
    }

    private void Method2()
    {
        // Implementação
    }
}

public class Class1
{
    private List<Class2> _listClass2 = new List<Class2>();

    public void AddClass2(string class2Name)
    {
        Class2 class2 = new Class2(class2Name, this);
        _listClass2.Add(class2);
    }
}

public class Class2
{
    private Class1 _class1;
    private string _name;

    public Class2(string name, Class1 class1)
    {
        this._class1 = class1;
        this._name = name;
    }

    public Class2(Class1 class1)
    {
        this._class1 = class1;
    }
}

// Atributos em C# usam colchetes [] em vez de @
[Layout(Level = 1, Order = 1)]
public class Class3 : IInterface1
{
    private Class1 _class1;

    public void Method1()
    {
        // Necessário implementar o método da interface
    }
}

// Herança usa ":" em vez de "extends"
public class Class4 : Class1
{
    public string Teste;
}

public class Class5 : Class1
{
    public string Teste;
}

public class Class6 : Class1
{
    public string Teste;
}
```
