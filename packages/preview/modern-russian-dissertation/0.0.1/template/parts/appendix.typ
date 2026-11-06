#import "@preview/modern-russian-dissertation:0.0.1": *
#show: phd-appendix 

= Примеры вставки листингов программного кода <app:A>
  
#figure(
  [```rust 
  pub fn main() {
    println!("Hello, world!");
  }
  ```],
  caption: [Листинг программного кода на языке программирования Rust]
)

#figure(
  [```python 
  def fibonaci(n):
    if n <= 1:
        return n
    else:
        return(fibonaci(n-1) + fibonaci(n-2))
  ```],
  caption: [Листинг программного кода на языке программирования Python]
)

= Очень длинное название второго приложения, в~котором продемонстрирована работа с~длинными таблицами <app:B>

== Подраздел приложения <app:B2>

#figure(
  table(
    columns: (1fr,1fr,1fr,1fr,),
    table.header([*Заголовок 1*],[*Заголовок 2*],
      [*Заголовок 3*],[*Заголовок 4*],),
      ..for x in range(1,50){
        ([#x],[#x],[#x],[#x],)
      }
  
  ),
  caption: [Очень длинное название таблицы]

)