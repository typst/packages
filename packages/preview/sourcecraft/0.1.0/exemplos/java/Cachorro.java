public class Cachorro extends Animal {
  private String raca;
  private Coleira coleira;
  private Dono dono;

  public Cachorro(Dono dono, String raca, Coleira coleira) {
    this.dono = dono;
    this.raca = raca;
    this.coleira = coleira;
  }

  public void latir() {
    Brinquedo b = new Brinquedo();
    System.out.println(b);
  }

  @Override
  public void emitirSom() {
    latir();
  }
}
