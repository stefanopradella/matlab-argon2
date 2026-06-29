function [J_1, J_2] = computeSlice_Argon2d(B, i, previousColumn)
% RFC 9106 - Section 3.4.1.1
% previousColumn is computed outside to handle wrap-around logic

    J_1 = blake2impl.bytesToWordVector(B(i, previousColumn, 1:4), 32, 1);
    J_2 = blake2impl.bytesToWordVector(B(i, previousColumn, 5:8), 32, 1);
end