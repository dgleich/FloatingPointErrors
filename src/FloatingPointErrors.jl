module FloatingPointErrors

using MultiFloats

""" 
    FloatWithError{T<:AbstractFloat, TE<:AbstractFloat}(value::T, valuehi::TE)

Create a representation of a floating point value an associated high precision type. 
The error term is computed with a higher precision floating point type, then 
we get the value from the original floating point type. 

f(x) is computed as f(x) in the base type T, then we also compute

""" 
struct FloatWithError{T<:AbstractFloat, TE<:AbstractFloat}
  value::T
  valuehi::TE # This represents the relvative error 
end 

function _additive_error(x::FloatWithError)
  return x.valuehi - x.value 
end

function Base.show(io::IO, x::FloatWithError)
  if x.value == 0 
    print(io, "0 + $(_additive_error(x))")
  else
    print(io, "$(x.value)⋅(1+$(errorterm(x)))")
  end 
end

_error_type(::Type{Float16}) = Float32
_error_type(::Type{Float32}) = Float64
_error_type(::Type{Float64}) = Float64x4 
_error_type(x::AbstractFloat) = _error_type(typeof(x))

FloatWithError(value::AbstractFloat) = FloatWithError(value, _error_type(value)(value))

function Base.convert(::Type{Float64}, x::FloatWithError)
  return Float64(x.value)
end

import Base.+, Base.*, Base./, Base.-


function +(x::FloatWithError, y::FloatWithError)
  T = promote_type(typeof(x.value), typeof(y.value))
  TE = promote_type(typeof(x.valuehi), typeof(y.valuehi))
  return FloatWithError(T(x.value) + T(y.value), TE(x.valuehi + y.valuehi))
end
function *(x::FloatWithError, y::FloatWithError)
  T = promote_type(typeof(x.value), typeof(y.value))
  TE = promote_type(typeof(x.valuehi), typeof(y.valuehi))
  return FloatWithError(T(x.value) * T(y.value), TE(x.valuehi * y.valuehi))
end
function -(x::FloatWithError, y::FloatWithError)
  T = promote_type(typeof(x.value), typeof(y.value))
  TE = promote_type(typeof(x.valuehi), typeof(y.valuehi))
  return FloatWithError(T(x.value) - T(y.value), TE(x.valuehi - y.valuehi))
end
function /(x::FloatWithError, y::FloatWithError)
  T = promote_type(typeof(x.value), typeof(y.value))
  TE = promote_type(typeof(x.valuehi), typeof(y.valuehi))
  return FloatWithError(T(x.value) / T(y.value), TE(x.valuehi / y.valuehi))
end
convert(::Type{Float64}, x::FloatWithError) = Float64(x.value)
convert(::Type{Float32}, x::FloatWithError) = Float32(x.value)
convert(::Type{FloatWithError}, x::Float64) = FloatWithError(x)

for func in [:+, :-, :*, :/]
  @eval begin
    import Base.$func
    function $func(x::FloatWithError, y::AbstractFloat)
      return $func(x, FloatWithError(y))
    end
    function $func(x::AbstractFloat, y::FloatWithError)
      return $func(FloatWithError(x), y)
    end
  end
end


funcs = [:sqrt, :sin, :cos, :tan, :abs, :adjoint]
for f in funcs
  @eval begin 
    import Base.$f
    function $f(x::FloatWithError)
      T = typeof(x.value)
      TE = typeof(x.valuehi)
      return FloatWithError($f(T(x.value)), TE($f(TE(x.valuehi))))
    end
  end 
end
import Base.length, Base.iterate
length(x::FloatWithError) = length(x.value)
iterate(x::FloatWithError) = iterate(x.value)
iterate(x::FloatWithError,::Nothing) = nothing 

""" 
    errorterm(x::FloatWithError)

Return the relative error term of the floating point value
based on the high precision value.
"""    
function errorterm(x::FloatWithError) 
  return (x.valuehi/x.value) - 1
end 

export errorterm, FloatWithError

end # module FloatingPointErrors
