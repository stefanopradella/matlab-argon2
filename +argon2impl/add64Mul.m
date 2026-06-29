function z = add64Mul(x, y)
% ADD64MUL Argon2 GB addition with 64-bit wrapping behavior.

    arguments
        x   (:, 1)  uint64
        y   (:, 1)  uint64
    end

    xy = blake2impl.add64(x, y);

    xLow = uint64(argon2impl.getLowerBits(x));
    yLow = uint64(argon2impl.getLowerBits(y));

    product = xLow .* yLow;
    product = blake2impl.add64(product, product);

    z = blake2impl.add64(xy, product);
end