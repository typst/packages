#import "@preview/mtret:0.1.0": *
#show: style



#fcode(caption: "va", label: <a>)[
  ```python
  # ほげ
  def kahan_add(vals: NDArray[np.float32]) -> np.float32:
      ans = np.float32(0)
      comp: np.float32 = np.float32(0)
      for x in vals:
          x -= comp
          temp: np.float32 = ans + x
          comp = (temp - ans) - x
          ans = temp
      return ans
  ```]

#ftext(caption: "hoge", placement: none)[
  ```
  aa
  ```
]

@a
#lorem(1000)

#fcode(caption: "va", label: <b>)[
  ```python
  # ほげ
  def kahan_add(vals: NDArray[np.float32]) -> np.float32:
      ans = np.float32(0)
      comp: np.float32 = np.float32(0)
      for x in vals:
          x -= comp
          temp: np.float32 = ans + x
          comp = (temp - ans) - x
          ans = temp
      return ans
  ```]

// #fimg("test.png", caption: "hoge")
