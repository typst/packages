#import "/lib.typ": *
#import "@preview/codly:1.1.1": *
#show: codly-init
#codly(languages: codly-languages)

```python
print("Hello, World!")
```

```java
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
```

```js
console.log("Hello, World!");
```

```cpp
#include <iostream>

int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}
```

```rust
fn main() {
    println!("Hello, World!");
}
```

```cs
using System;

class Program {
    static void Main() {
        Console.WriteLine("Hello, World!");
    }
}
```

```go
package main

import "fmt"

func main() {
    fmt.Println("Hello, World!")
}
```

```swift
print("Hello, World!")
```

```php
<?php
  echo "Hello, World!";
?>
```

```kotlin
fun main() {
    println("Hello, World!")
}
```
