# boxproof-typst

This is the typst port of https://github.com/YunkaiZhang233/boxproof

此仓库为 https://github.com/YunkaiZhang233/boxproof 的typst版本

In particular, it allows you to easily write boxed-style natural deduction proofs.

简单来说，这个库的作用是辅助你快速写出漂亮的自然推理证明。

```typst
#start(
  pf(
    ($K <-> not B$, premise),
    pfbox(
      ($K <-> B$, ass),
      ($K or not K$, lem),
      cases(
        pf(
          ($K$, ass),
          ($B$, iffe(2, 4)),
          ($not B$, iffe(1, 4)),
          ($bot$, fi(5, 6)),
          ($bot$, tick(7)),
        ),
        pf(
          ($not K$, ass),
          ($B or not B$, lem),
          cases(
            pf(
              ($B$, ass),
              ($K$, iffe(2, 11)),
              ($bot$, fi(12, 9)),
              ($bot$, tick(13)),
            ),
            pf(
              ($not B$, ass),
              ($K$, iffe(1, 15)),
              ($bot$, fi(16, 9)),
            ),
          ),
          ($bot$, ore(10, 11, 14, 15, 17)),
        ),
      ),
      ($bot$, ore(4, 4, 8, 9, 18)),
      ($not (K <-> B)$, noti(2, 19)),
    ),
  ),
)
```

![preview](https://github.com/user-attachments/assets/ccb26bc4-746f-4026-9f21-b66259770544)

Credits:

致谢：

- https://github.com/YunkaiZhang233/boxproof
- https://github.com/0rphee/derive-it
