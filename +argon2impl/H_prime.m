function result = H_prime(A, T)
% RFC 9106 - Section 3.3
 
    if T <= 64
        result= blake2b([argon2impl.LE32(T); A], T);
        return
    else
        r = ceil(T/32)-2;
        V = zeros(64, r+1, 'uint8');

        V(:, 1) = blake2b([argon2impl.LE32(T); A],64);
        for iBlock = 2:r
            V(:, iBlock) = blake2b(V(:, iBlock-1), 64);
        end
        V_final = blake2b(V(:, r), (T-(32*r)));
        
        result = zeros(32*r + (T-(32*r)), 1, 'uint8');

        for iBlock = 1:r
            result(((iBlock-1)*32)+1 : (iBlock)*32) = V(1:32, iBlock);
        end
        result((iBlock*32)+1:end) = V_final;
    end 
end