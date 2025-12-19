#import "@preview/boxproof:0.1.0": *

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
