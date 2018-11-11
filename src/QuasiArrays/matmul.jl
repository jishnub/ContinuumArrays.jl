
const QuasiArrayMulArray{styleA, styleB, p, q, T, V} =
    Mul2{styleA, styleB, <:AbstractQuasiArray{T,p}, <:AbstractArray{V,q}}

const QuasiArrayMulQuasiArray{styleA, styleB, p, q, T, V} =
    Mul2{styleA, styleB, <:AbstractQuasiArray{T,p}, <:AbstractQuasiArray{V,q}}
####
# Matrix * Vector
####
const QuasiMatMulVec{styleA, styleB, T, V} = QuasiArrayMulArray{styleA, styleB, 2, 1, T, V}


function getindex(M::QuasiMatMulVec, k::Real)
    A,B = M.factors
    ret = zero(eltype(M))
    @inbounds for j = 1:size(A,2)
        ret += A[k,j] * B[j]
    end
    ret
end

function getindex(M::QuasiMatMulVec, k::AbstractArray)
    A,B = M.factors
    ret = zeros(eltype(M),length(k))
    @inbounds for j = 1:size(A,2)
        ret .+= view(A,k,j) .* B[j]
    end
    ret
end


QuasiMatMulMat{styleA, styleB, T, V} = QuasiArrayMulArray{styleA, styleB, 2, 2, T, V}
QuasiMatMulQuasiMat{styleA, styleB, T, V} = QuasiArrayMulQuasiArray{styleA, styleB, 2, 2, T, V}

*(A::AbstractQuasiArray, B::AbstractQuasiArray, C::AbstractQuasiArray) = materialize(Mul(A,B,C))
*(A::AbstractQuasiArray, B::AbstractQuasiArray) = materialize(Mul(A,B))
*(A::AbstractQuasiArray, B::AbstractArray) = materialize(Mul(A,B))
*(A::AbstractArray, B::AbstractQuasiArray) = materialize(Mul(A,B))
pinv(A::AbstractQuasiArray) = materialize(PInv(A))
inv(A::AbstractQuasiArray) = materialize(Inv(A))

*(A::AbstractQuasiArray, B::Mul) = materialize(Mul(A, B.factors...))
*(A::Mul, B::AbstractQuasiArray) = materialize(Mul(A.factors..., B))