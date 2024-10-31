## Nick Trefethen, September 2024
# Here's an experiment Nick Trefethen did in September 2024. 

n = 10^6
x = rand(n)
y = 1 .- x 
s = sum(x) + sum(y)
e = s - n # should be sqrt(eps)*n ~ 1.5e-8*n
# but it is much more accurate than that

## Using this package
using FloatingPointErrors
xe = FloatWithError.(x)
ye = map(v->FloatWithError(1.0) - v, xe) # compute 1-x with error
se = sum(xe) + sum(ye)
@show se
@show sum(xe)
@show sum(ye)

##
v = FloatWithError(rand())
w = FloatWithError(rand())
@show v
@show w
v+w 

