public class Gato extends Animal implements Alimentavel {
  private boolean domestico;

  public Gato(boolean domestico) {
    this.domestico = domestico;
  }

  @Override
  public void alimentar() {
    System.out.println("Gato alimentado: " + domestico);
  }

  @Override
  public void emitirSom() {
    System.out.println("Miau!");
  }
}
