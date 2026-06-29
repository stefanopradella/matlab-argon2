function tag = argon2(P, S, p, T, m, t, y, K, X)
% https://datatracker.ietf.org/doc/rfc9106
    
    arguments
        P   (:, 1)      % Message string
        S   (:, 1)      % Nonce
        p   (1, 1)      % Parallellism: number of lanes
        T   (1, 1)      % Tag length
        m   (1, 1)      % Memory size [kb]
        t   (1, 1)      % Number of passes
        y   (1, 1)      % Type (0 for Argon2d, 1 for Argon2i, 2 for Argon2id)
        K   (:, 1)      % Secret value
        X   (:, 1)      % Associated data
    end

    v = 0x13;   % Version number is fixed
    
    H_0 = blake2b([ argon2impl.LE32(p); ...
                    argon2impl.LE32(T); ...
                    argon2impl.LE32(m); ...
                    argon2impl.LE32(t); ...
                    argon2impl.LE32(v); ...
                    argon2impl.LE32(y); ...
                    argon2impl.LE32(numel(P)); ...
                    P; ...
                    argon2impl.LE32(numel(S)); ...
                    S; ...
                    argon2impl.LE32(numel(K)); ...
                    K; ...
                    argon2impl.LE32(numel(X)); ...
                    X], 64);

    m_prime = 4 * p * floor(m / (4*p));

    % Allocate the memory matrix
    q = m_prime/p;

    B = zeros(p, q, 1024, 'uint8');

    % Compute lane blocks 1 and 2
    for i = 1:p
        B(i, 1, :) = argon2impl.H_prime([H_0; argon2impl.LE32(0); argon2impl.LE32(i-1)], 1024);
        B(i, 2, :) = argon2impl.H_prime([H_0; argon2impl.LE32(1); argon2impl.LE32(i-1)], 1024);
    end

    % Compute other blocks
    columnsPerSlice = q/4;

    for iPass=1:t
        for iSlice = 1:4
            for iLane = 1:p
                if iPass == 1 && iSlice == 1
                    firstColumn = 3;
                else
                    firstColumn = (columnsPerSlice*(iSlice-1)) + 1;
                end

                lastColumn = columnsPerSlice*iSlice;

                % Guard for first pass with small memory
                if firstColumn > lastColumn
                    continue
                end

                % Logic to handle block indexing
                if y == 1 || (y==2 && (iPass == 1 && (iSlice < 3)))
                    [J_1, J_2] = argon2impl.computeSlice_Argon2i(iPass, iLane, iSlice, m_prime, t , y, p);
                    computeArgon2dIndexes = false;
                else
                    computeArgon2dIndexes = true;
                end

                % Mapping J_1 and J_2 to Reference Block Index [l][z]
                for iColumn = firstColumn:lastColumn

                    % Wrap-around logic for start of new pass
                    if iColumn == 1
                        previousColumn = q;
                    else
                        previousColumn = iColumn - 1;
                    end

                    positionIndex = iColumn - (columnsPerSlice*(iSlice-1));

                    % If J-1 and J-2 have been precomputed extract the
                    % index, otherwise do the calculation 
                    if computeArgon2dIndexes
                        [j1, j2] = argon2impl.computeSlice_Argon2d(B, iLane, previousColumn);
                    else
                        j1 = J_1(positionIndex);
                        j2 = J_2(positionIndex);
                    end
        
                    % Calculate l
                    if iPass==1 && iSlice == 1
                        l = iLane;
                    else
                        l = mod(j2, p) + 1;
                    end

                    % Calculate z
                    if l == iLane
                        if iPass == 1
                            if iSlice == 1
                                referenceAreaSize = positionIndex - 2;
                            else
                                referenceAreaSize = (iSlice - 1)*columnsPerSlice + positionIndex - 2;
                            end
                        else
                            referenceAreaSize = q - columnsPerSlice + positionIndex - 2;
                        end
                    else
                        if iPass == 1
                            referenceAreaSize = (iSlice - 1)*columnsPerSlice;
                        else
                            referenceAreaSize = q - columnsPerSlice;
                        end

                        if positionIndex == 1
                            referenceAreaSize = referenceAreaSize - 1;
                        end
                    end

                    % Extract block using approximation
                    x = bitshift(uint64(j1) * uint64(j1), -32);
                    yIndex = bitshift(uint64(referenceAreaSize) * x, -32);
                    zz = double(uint64(referenceAreaSize - 1) - yIndex);

                    % Select z value from  
                    if iPass == 1 || iSlice == 4
                        startPosition = 0;
                    else
                        startPosition = iSlice*columnsPerSlice;
                    end

                    z = mod(startPosition + zz, q) + 1;

                    previousBlock = squeeze(B(iLane, previousColumn, :));
                    referenceBlock = squeeze(B(l, z, :));
                    newBlock = argon2impl.G(previousBlock, referenceBlock);

                    if iPass > 1
                        newBlock = bitxor(newBlock, squeeze(B(iLane, iColumn, :)));
                    end

                    B(iLane, iColumn, :) = reshape(newBlock, 1, 1, []);
                end
            end
        end
    end
    finalBlock = squeeze(B(1, q, :));
    for iLane = 2:p
        finalBlock = bitxor(finalBlock, squeeze(B(iLane, q, :)));
    end

    tag = argon2impl.H_prime(finalBlock, T);
end