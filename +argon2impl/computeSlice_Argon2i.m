function [J_1, J_2] = computeSlice_Argon2i(r, l, sl, m_prime, t, y, p)
%COMPUTESLICE_ARGON2I Compute Argon2i indexing values for one segment.
% RFC 9106 - Section 3.4.1.2.

    arguments
        r           (1, 1)
        l           (1, 1)
        sl          (1, 1)
        m_prime     (1, 1)
        t           (1, 1)
        y           (1, 1)
        p           (1, 1)
    end


    Z = [   argon2impl.LE64(r-1); ...
            argon2impl.LE64(l-1); ...
            argon2impl.LE64(sl-1); ...
            argon2impl.LE64(m_prime); ...
            argon2impl.LE64(t); ...
            argon2impl.LE64(y)];
    
    % Calculate numAddrBlocks instead of doing q/(128*SL)
    SL                  =   4;
    q                   =   m_prime / p;
    numAddrBlocks       =   ceil(q/(128*SL));
    blocksPerSegment    =   q/SL;

    addrBlocks      =   zeros(1024, numAddrBlocks, 'uint8');
    zeroBlock       =   zeros(1024, 1, 'uint8');
    padBlock        =   zeros(968, 1, 'uint8');

    J_1 = zeros(blocksPerSegment, 1, 'uint32');
    J_2 = zeros(blocksPerSegment, 1, 'uint32');
    blockAddr = 1;

    for iBlock = 1:numAddrBlocks
        addrBlocks(:, iBlock) = argon2impl.G(zeroBlock, argon2impl.G(zeroBlock, [Z; argon2impl.LE64(iBlock); padBlock]));
        for iChunk = 1:128
            chunkAddr = (8*(iChunk-1))+1:8*iChunk;
            J_1(blockAddr) = blake2impl.bytesToWordVector(addrBlocks(chunkAddr(1:4), iBlock), 32, 1);
            J_2(blockAddr) = blake2impl.bytesToWordVector(addrBlocks(chunkAddr(5:8), iBlock), 32, 1);
            if blockAddr == blocksPerSegment
                break
            else 
                blockAddr = blockAddr + 1;
            end
        end
    end

end
