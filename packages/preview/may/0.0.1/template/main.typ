#import "@preview/may:0.0.1": *
#show: may-sans
// Some other variants
// #show: may
// #show: may-serif

= May

>| A simple and elegant template for multiple daily tasks

#lorem(24)

== Tables and Wraps

#wrap-content(
  figure(table(
    columns: 3,
    "Benchmark", "A/%", "B/%",
    table.hline(),
    "jo", "13.3", "33.2",
    "jojo", "11.1", "28.3",
    "ours", "100.0", "100.0",
    table.hline()
  ), caption: [A sample table, ours is the best.]),
  lorem(60),
  align: right
)

== Codeblocks and Formulas

$
vb(x)_(t+1) &= sqrt(macron(alpha)_t) vb(x)_0 + sqrt(1 - macron(alpha)_t) vb(epsilon) quad &"Forward"\
vb(x)_(t-1) &= 1/sqrt(1 - beta_t) (vb(x)_t - (beta_t)/sqrt(1 - macron(alpha)_t) vb(epsilon)_theta (vb(x)_t, t)) + sqrt(beta_t) vb(epsilon) quad &"Backward"
$

```python
# DDPM step
def p_sample_ddpm(self, model: nn.Module, x_t: torch.Tensor, t: torch.Tensor):
    eps = model(x_t, t)
    beta_t = self.betas[t][:, None, None, None]
    alpha_t = self.alphas[t][:, None, None, None]
    alpha_bar_t = self.alpha_bars[t][:, None, None, None]
    sqrt_one_minus_alpha_bar_t = self.sqrt_one_minus_alpha_bars[t][:, None, None, None]
    mean = 1 / torch.sqrt(alpha_t) * (x_t - beta_t / sqrt_one_minus_alpha_bar_t * eps)
    if (t == 0).all():
        return mean
    noise = torch.randn_like(x_t)
    sigma = torch.sqrt(beta_t)
    return mean + sigma * noise
```
