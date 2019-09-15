module ContinuumArrays
using IntervalSets, LinearAlgebra, LazyArrays, FillArrays, BandedMatrices, InfiniteArrays, DomainSets, InfiniteLinearAlgebra, QuasiArrays
import Base: @_inline_meta, axes, getindex, convert, prod, *, /, \, +, -,
                IndexStyle, IndexLinear, ==, OneTo, tail, similar, copyto!, copy,
                first, last
import Base.Broadcast: materialize, BroadcastStyle
import LazyArrays: MemoryLayout, Applied, ApplyStyle, flatten, _flatten, colsupport, adjointlayout, LdivApplyStyle
import LinearAlgebra: pinv
import BandedMatrices: AbstractBandedLayout, _BandedMatrix
import FillArrays: AbstractFill, getindex_value

import QuasiArrays: cardinality, checkindex, QuasiAdjoint, QuasiTranspose, Inclusion, SubQuasiArray,
                    QuasiDiagonal, MulQuasiArray, MulQuasiMatrix, MulQuasiVector, QuasiMatMulMat,
                    ApplyQuasiArray, ApplyQuasiMatrix, LazyQuasiArrayApplyStyle, AbstractQuasiArrayApplyStyle,
                    LazyQuasiArray, LazyQuasiVector, LazyQuasiMatrix, LazyLayout, LazyQuasiArrayStyle

export Spline, LinearSpline, HeavisideSpline, DiracDelta, Derivative, 
            Jacobi, Legendre, Chebyshev, Ultraspherical,
            JacobiWeight, ChebyshevWeight, UltrasphericalWeight,
            fullmaterialize

####
# Interval indexing support
####
struct AlephInfinity{N} <: Integer end

==(::AlephInfinity, ::Int) = false
==(::Int, ::AlephInfinity) = false

const ℵ₁ = AlephInfinity{1}()


const QMul2{A,B} = Mul{<:AbstractQuasiArrayApplyStyle, <:Tuple{A,B}}
const QMul3{A,B,C} = Mul{<:AbstractQuasiArrayApplyStyle, <:Tuple{A,B,C}}

cardinality(::AbstractInterval) = ℵ₁
*(ℵ::AlephInfinity) = ℵ

first(S::Inclusion{<:Any,<:AbstractInterval}) = leftendpoint(S.domain)
last(S::Inclusion{<:Any,<:AbstractInterval}) = rightendpoint(S.domain)


checkindex(::Type{Bool}, inds::AbstractInterval, i::Number) = (leftendpoint(inds) <= i) & (i <= rightendpoint(inds))
checkindex(::Type{Bool}, inds::AbstractInterval, i::Inclusion) = i.domain ⊆ inds
function checkindex(::Type{Bool}, inds::AbstractInterval, I::AbstractArray)
    @_inline_meta
    b = true
    for i in I
        b &= checkindex(Bool, inds, i)
    end
    b
end


# we represent as a Mul with a banded matrix
function materialize(V::SubQuasiArray{<:Any,2,<:Any,<:Tuple{<:Inclusion,<:AbstractUnitRange}})
    A = parent(V)
    _,jr = parentindices(V)
    first(jr) ≥ 1 || throw(BoundsError())
    P = _BandedMatrix(Ones{Int}(1,length(jr)), axes(A,2), first(jr)-1,1-first(jr))
    A*P
end

BroadcastStyle(::Type{<:Inclusion{<:Any,<:AbstractInterval}}) = LazyQuasiArrayStyle{1}()

include("operators.jl")
include("bases/bases.jl")

end
