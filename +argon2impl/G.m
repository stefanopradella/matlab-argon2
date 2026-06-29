function result = G(X, Y)
% RFC 9106 - Section 3.5
    
    arguments
        X   (1024, 1)  uint8
        Y   (1024, 1)  uint8
    end

    R = reshape(bitxor(X, Y), 16, 8, 8);

    Q = zeros(16, 8, 8, 'uint8');
    Z = zeros(16, 8, 8, 'uint8');

    for rowIndex = 1:8
        Q(:, :, rowIndex) = argon2impl.P(R(:, :, rowIndex));
    end

    for columnIndex = 1:8
        Z(:, columnIndex, :) = reshape( ...
            argon2impl.P(squeeze(Q(:, columnIndex, :))), 16, 1, 8);
    end

    result = reshape(bitxor(Z, R), 1024, 1);
end