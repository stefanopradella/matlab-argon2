function words = bytesToUint64(bytes)
% BYTESTOUINT64 Convert little-endian byte strings to uint64 words.

    arguments
        bytes   (:, 1)  uint8
    end

    words = zeros(numel(bytes)/8, 1, 'uint64');

    for byteIndex = 1:8
        words = bitor(words, bitshift(uint64(bytes(byteIndex:8:end)), 8*(byteIndex - 1)));
    end
end