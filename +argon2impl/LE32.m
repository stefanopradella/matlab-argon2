function b = LE32(a)
% LE32A - Return 32-bit little endian representation of input

    arguments
        a   (1,1)   uint32
    end

    b = uint8([
        bitand(a, uint32(255))
        bitand(bitshift(a, -8),  uint32(255))
        bitand(bitshift(a, -16), uint32(255))
        bitand(bitshift(a, -24), uint32(255))
    ]);
end