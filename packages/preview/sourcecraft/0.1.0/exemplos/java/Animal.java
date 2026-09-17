public abstract class Animal {
  private String nome;
  private int idade;
  private Dono dono;

  public String getNome() {
    return nome;
  }

  public int getIdade() {
    return idade;
  }

  public Dono getDono() {
    return dono;
  }

  public abstract void emitirSom();
}
