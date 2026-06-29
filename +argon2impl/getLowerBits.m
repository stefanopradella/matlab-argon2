function y = getLowerBits(x)
% ARGON2IMPL.GETLOWERBITS(x) - get the lower 32 bits of uint64 input x

    arguments
        x   (:, :)  uint64
    end

    bitmask = 0x00000000FFFFFFFF;

    y = uint32(bitand(x, bitmask));
end