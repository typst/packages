#import "../lib.typ": *


#show: doc.with(
  title: ("Introduction", "Hilbert"),
  
  outline: true,
  title-page: true,
  smallcaps: true,
)


= Introduction to Hilbert Spaces

#para("Definition")[A Hilbert space H is a complete inner product space. That is, it is a vector space with an inner product that is also complete with respect to the distance function induced by the inner product.]

#inbox[
  The inner product $angle.l x, y angle.r$ induces a norm through:
  $norm(x) = root(angle.l x, x angle.r)$
]

== Fundamental Properties

=== The Projection Theorem

#ex[In a Hilbert space H, for any closed subspace M and any point x ∈ H, there exists a unique point y ∈ M such that:
$norm(x - y) = inf_(z in M) norm(x - z)$
]

#plotting(
  (
    (
      fn: x => x*calc.sin(x)/2,
      domain: (-5, 5),
      projection: (
        x: (2,),
        y: (2,),
      ),
    ),
  ),
  domain: (-5, 5),
  steps: (1, 1),
  axis: ($x$, $y$),
)

=== Orthogonal Decomposition

#rq[For any closed subspace M of a Hilbert space H:
- H = M ⊕ M^⊥
- Every element x ∈ H can be uniquely written as x = y + z where y ∈ M and z ∈ M^⊥]

#ex[Consider the space $L^2([0,1])$ with the subspace of constant functions:
$M = {f in L^2([0,1]) | f "is constant"}$
]

== Operators on Hilbert Spaces


#inbox2[
  A bounded linear operator T on a Hilbert space H is:
  - *Self-adjoint* if $angle.l T x,y angle.r = angle.l x,T y angle.r$ for all x,y ∈ H
  - *Compact* if it maps bounded sets to relatively compact sets
  - *Normal* if $T T^* = T^* T$
]

=== The Spectral Theorem

#recurrence(
  p: "For any compact self-adjoint operator T on a Hilbert space H",
  d: "λ ∈ σ(T)",
  ini: [
    There exists an orthonormal basis {$e_n$} of H consisting of eigenvectors of T:
    $T e_n = lambda_n e_n$
    where $lambda_n$ are the eigenvalues of T.
  ],
  hd: [
    Moreover, if T is compact:
    - The spectrum σ(T) is countable
    - 0 is the only possible accumulation point of σ(T)
    - Each non-zero λ ∈ σ(T) is an eigenvalue of finite multiplicity
  ],
  cl: [
    This allows us to represent T as:
    $T = sum_(n=1)^∞ lambda_n angle.l dot, e_n angle.r e_n$
  ]
)

= Applications in Quantum Mechanics

#para("Definition")[The state space of a quantum system is modeled by a complex Hilbert space H, where:
- Physical observables are represented by self-adjoint operators
- The evolution of the system is given by the Schrödinger equation]

#arrow-list(
  [Wave functions are elements of $L^2(RR^3)$],
  [The momentum operator is $P = -i bar nabla$],
  [The position operator is multiplication by x]
)

= Python Implementation

#para("Code")[Here is a Python implementation of the concepts presented above:]
```python
import numpy as np
from scipy.integrate import quad
from scipy.linalg import eigh
import matplotlib.pyplot as plt

class HilbertSpace:
    """Class representing a Hilbert space L²([a,b])"""
    
    def __init__(self, a=0, b=1):
        self.a = a
        self.b = b
    
    def inner_product(self, f, g):
        """Calculation of the inner product in L²"""
        return quad(lambda x: f(x) * np.conjugate(g(x)), 
                   self.a, self.b)[0]
    
    def norm(self, f):
        """Calculation of the induced norm"""
        return np.sqrt(self.inner_product(f, f))
    
    def project(self, f, subspace_basis):
        """Projection onto a closed subspace"""
        projection = lambda x: 0
        for basis_fn in subspace_basis:
            coeff = self.inner_product(f, basis_fn)
            projection = lambda x, p=projection: (
                p(x) + coeff * basis_fn(x)
            )
        return projection

# Example of use
H = HilbertSpace(-np.pi, np.pi)

# Fourier basis
e1 = lambda x: 1/np.sqrt(2*np.pi)
e2 = lambda x: np.cos(x)/np.sqrt(np.pi)
e3 = lambda x: np.sin(x)/np.sqrt(np.pi)

# Function to project
f = lambda x: x**2

# Projection onto the space spanned by {e1, e2, e3}
proj_f = H.project(f, [e1, e2, e3])

# Visualization
x = np.linspace(-np.pi, np.pi, 200)
plt.figure(figsize=(10, 6))
plt.plot(x, [f(xi) for xi in x], 'b-', label='Original function')
plt.plot(x, [proj_f(xi) for xi in x], 'r--', 
         label='Projection (truncated Fourier series)')
plt.legend()
plt.grid(True)
plt.title('Projection in L²([-π,π])')
```

This implementation illustrates:
#arrow-list(
  [The structure of a Hilbert space with its inner product],
  [The projection theorem onto a closed subspace],
  [The approximation by Fourier series]
)
