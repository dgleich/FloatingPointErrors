""" Do an example with LU factorization. """

using LinearAlgebra, FloatingPointErrors
function solve1(A::Matrix, b::Vector)
  m,n = size(A)
  @assert(m==n, "the system is not square")
  @assert(n==length(b), "vector b has the wrong length")
  if n==1
    return [b[1]/A[1]]
  else
    D = A[2:end,2:end]
    c = A[1,2:end]
    d = A[2:end,1]
    α = A[1,1]
    y = solve1(D.-(d*c')./α, b[2:end]-(b[1]./α).*d)
    γ = (b[1] - c'*y)/α
    return pushfirst!(y,γ)
  end
end

using FloatingPointErrors, Random 

Random.seed!(1234)
A = rand(10,10)
b = rand(10)

A = FloatWithError.(A)
b = FloatWithError.(b)

x = solve1(A,b)

##
using LinearAlgebra
n = 60
A = -tril(ones(n,n))
A = A + 2I
A[:,end] .= 1.0
#x = ones(n)
x = Float64.(rand(-1:2:1,n))
b = A*x
##
A = FloatWithError.(A)
b = FloatWithError.(b)
x = solve1(A,b)
##
n = 10
A = -tril(ones(n,n))
A = A + 2I
A[:,end] .= 1.0
x = Float64.(rand(-1:2:1,n))
b = A*x
using MultiFloats
Ahi = Float64x4.(A)
bhi = Float64x4.(b)
z = solve1(Ahi,bhi)

##




