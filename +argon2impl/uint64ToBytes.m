function bytes = uint64ToBytes(words)
% UINT64TOBYTES Convert uint64 words to little-endian byte strings.

    arguments
        words   (:, 1)  uint64
    end

    bytes = zeros(8*numel(words), 1, 'uint8');

    for byteIndex = 1:8
        bytes(byteIndex:8:end) = uint8(bitand(bitshift(words, -8*(byteIndex - 1)), uint64(255)));
    end
end