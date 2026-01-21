#{
import "lib.typ": round  
let shouldBeEqualTo(x, y) = assert(x == y);

shouldBeEqualTo(round(0.0, 4), "0.000");
shouldBeEqualTo(round(-0.0, 4), "0.000");
shouldBeEqualTo(round(1234.567, 8), "1234.5670");
shouldBeEqualTo(round(1234.567, 1), "1e3");
shouldBeEqualTo(round(1234.567, "1"), "1e3"); // just like 1
shouldBeEqualTo(round(1234.567, 2), "1.2e3");
shouldBeEqualTo(round(1234.567, 2.9), "1.2e3");
shouldBeEqualTo(round(1234.567, 5), "1234.6");
// shouldBeEqualTo(round(1234.567, 21), "1234.56700000000000728"); // integer overflow
}
