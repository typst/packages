"""
	out = square(x::Complex)

Computes the square of an 𝑥 ∊ ℝ.

"""
function square(x::Real)
	x * x
end

"""
	out = square(x::Complex)

Computes the square of an 𝑥 ∊ ℂ.

"""
function square(x::Complex)
	conj(x) * x
end
