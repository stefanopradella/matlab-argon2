function b = LE64(a)
% LE64A - Return 64-bit little endian representation of input

    arguments
        a   (1,1)   uint64
    end

    b = uint8([
        bitand(a, uint64(255))
        bitand(bitshift(a, -8),  uint64(255))
        bitand(bitshift(a, -16), uint64(255))
        bitand(bitshift(a, -24), uint64(255))
        bitand(bitshift(a, -32), uint64(255))
        bitand(bitshift(a, -40), uint64(255))
        bitand(bitshift(a, -48), uint64(255))
        bitand(bitshift(a, -56), uint64(255))
    ]);
end
