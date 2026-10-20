#figure(
  [```
  \begin{algorithm}
  \caption{Vypočítaj $y = x^n$}
  \label{alg:calculation-1}
  \begin{algorithmic}
      \REQUIRE $n \geq 0 \vee x \neq 0$
      \ENSURE $y = x^n$
      \STATE $y \Leftarrow 1$
      \IF{$n < 0$}
          \STATE $X \Leftarrow 1 / x$
          \STATE $N \Leftarrow -n$
      \ELSE
          \STATE $X \Leftarrow x$
          \STATE $N \Leftarrow n$
      \ENDIF
      \WHILE{$N \neq 0$}
          \IF{$N$ is even}
              \STATE $X \Leftarrow X \times X$
              \STATE $N \Leftarrow N / 2$
          \ELSE[$N$ is odd]
              \STATE $y \Leftarrow y \times X$
              \STATE $N \Leftarrow N - 1$
          \ENDIF
      \ENDWHILE
  \end{algorithmic}
  \end{algorithm}

  ```],
) <att:listings>
