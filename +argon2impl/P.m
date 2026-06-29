function result = P(S)
% RFC 9106 - Section 3.6

    arguments
        S   (16, 8)  uint8
    end

    R = blake2impl.Constants.BLAKE2b.R;
    v = argon2impl.bytesToUint64(S(:));
    zero = uint64(0);

    v = blake2impl.G(v, 1, 5, 9,  13, zero, zero, R, @argon2impl.add64Mul, @blake2impl.ror64);
    v = blake2impl.G(v, 2, 6, 10, 14, zero, zero, R, @argon2impl.add64Mul, @blake2impl.ror64);
    v = blake2impl.G(v, 3, 7, 11, 15, zero, zero, R, @argon2impl.add64Mul, @blake2impl.ror64);
    v = blake2impl.G(v, 4, 8, 12, 16, zero, zero, R, @argon2impl.add64Mul, @blake2impl.ror64);

    v = blake2impl.G(v, 1, 6, 11, 16, zero, zero, R, @argon2impl.add64Mul, @blake2impl.ror64);
    v = blake2impl.G(v, 2, 7, 12, 13, zero, zero, R, @argon2impl.add64Mul, @blake2impl.ror64);
    v = blake2impl.G(v, 3, 8, 9,  14, zero, zero, R, @argon2impl.add64Mul, @blake2impl.ror64);
    v = blake2impl.G(v, 4, 5, 10, 15, zero, zero, R, @argon2impl.add64Mul, @blake2impl.ror64);

    result = reshape(argon2impl.uint64ToBytes(v), 16, 8);
end
