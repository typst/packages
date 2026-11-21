# blue-ledger

Printable **injection log sheets** for Typst: a ruled table with your own columns, a **six-site rotation key**, and a helper that suggests the **least recently used** injection site.

```typ
#import "@preview/blue-ledger:0.1.0": *

#shot-log(rows: 12, title: "My weekly shot log")
#site-key()
#next-site(("Abdomen, left", "Thigh, right"))  // "Abdomen, right"
```

Useful for paper logs of weekly or daily injections (insulin, GLP-1 pens and similar), clinic handouts and nursing course material.

**Logging only:** this package never recommends or calculates doses. Follow your medicine's instructions and your healthcare provider.

Background on rotating injection sites: [bluedoseapp.com](https://bluedoseapp.com/features/injection-site-rotation-app/). A LaTeX version is on CTAN (`shotlog`).

MIT License.
