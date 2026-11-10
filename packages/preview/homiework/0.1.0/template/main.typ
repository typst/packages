#import "@preview/homiework:0.1.0": homework

#show: homework.with(
  course: "MATH 000",
  semester: "Spring 20XX",
  number: "X",
  date: datetime(year: 2026, month: 3, day: 24),
)

= Problem 1

Given $integral_(-infinity)^infinity |Psi(x,t)|^2 =1$
```python
def mean(x):
  total = 0
  for i in x:
    total += i
  return total / len(x)
```

#align(center)[
  #rect[$ E = m c^2 $]
]

= Problem 2
Lorem ipsum dolor sit amet consectetur adipiscing elit. Quisque faucibus ex sapien vitae pellentesque sem placerat. In id cursus mi pretium tellus duis convallis. Tempus leo eu aenean sed diam urna tempor. Pulvinar vivamus fringilla lacus nec metus bibendum egestas. Iaculis massa nisl malesuada lacinia integer nunc posuere. Ut hendrerit semper vel class aptent taciti sociosqu. Ad litora torquent per conubia nostra inceptos himenaeos.

Lorem ipsum dolor sit amet consectetur adipiscing elit. Quisque faucibus ex sapien vitae pellentesque sem placerat. In id cursus mi pretium tellus duis convallis. Tempus leo eu aenean sed diam urna tempor. Pulvinar vivamus fringilla lacus nec metus bibendum egestas. Iaculis massa nisl malesuada lacinia integer nunc posuere. Ut hendrerit semper vel class aptent taciti sociosqu. Ad litora torquent per conubia nostra inceptos himenaeos.

Lorem ipsum dolor sit amet consectetur adipiscing elit. Quisque faucibus ex sapien vitae pellentesque sem placerat. In id cursus mi pretium tellus duis convallis. Tempus leo eu aenean sed diam urna tempor. Pulvinar vivamus fringilla lacus nec metus bibendum egestas. Iaculis massa nisl malesuada lacinia integer nunc posuere. Ut hendrerit semper vel class aptent taciti sociosqu. Ad litora torquent per conubia nostra inceptos himenaeos.

Lorem ipsum dolor sit amet consectetur adipiscing elit. Quisque faucibus ex sapien vitae pellentesque sem placerat. In id cursus mi pretium tellus duis convallis. Tempus leo eu aenean sed diam urna tempor. Pulvinar vivamus fringilla lacus nec metus bibendum egestas. Iaculis massa nisl malesuada lacinia integer nunc posuere. Ut hendrerit semper vel class aptent taciti sociosqu. Ad litora torquent per conubia nostra inceptos himenaeos.

Lorem ipsum dolor sit amet consectetur adipiscing elit. Quisque faucibus ex sapien vitae pellentesque sem placerat. In id cursus mi pretium tellus duis convallis. Tempus leo eu aenean sed diam urna tempor. Pulvinar vivamus fringilla lacus nec metus bibendum egestas. Iaculis massa nisl malesuada lacinia integer nunc posuere. Ut hendrerit semper vel class aptent taciti sociosqu. Ad litora torquent per conubia nostra inceptos himenaeos.

```matlab
T0 = 150;   
Tenv = 25;    
k = 0.1;   
tspan = [0, 50];

t_ana = linspace(0, 50, 500);
T_ana = Tenv + (T0 - Tenv) .* exp(-k .* t_ana);

odefun = @(t, T) -k * (T - Tenv);
[t_ode, T_ode] = ode45(odefun, tspan, T0);

dt = 0.5;       
t_rk = 0:dt:50;
T_rk = zeros(size(t_rk));
T_rk(1) = T0;

for i = 1:length(t_rk)-1
    ti = t_rk(i);
    Ti = T_rk(i);
    f  = @(t, T) -k * (T - Tenv);
    k1 = f(ti,        Ti);
    k2 = f(ti + dt/2, Ti + dt/2 * k1);
    k3 = f(ti + dt/2, Ti + dt/2 * k2);
    k4 = f(ti + dt,   Ti + dt   * k3);
    T_rk(i+1) = Ti + (dt/6) * (k1 + 2*k2 + 2*k3 + k4);
end

```
