classdef TestArgon2 < matlab.unittest.TestCase

    methods (Test)
        function Argon2id_RFC9106(testCase)
            % RFC 9106 - Section 5.3

            password        = char(repelem(uint8(1), 32, 1));
            salt            = char(repelem(uint8(2), 16, 1));
            p               = 4;
            T               = 32;
            m               = 32;
            nPasses         = 3;
            secret          = char(repelem(uint8(3), 8, 1));
            associatedData  = char(repelem(uint8(4), 12, 1));
            expectedValue   = '0D640DF58D78766C08C037A34A8B53C9D01EF0452D75B65EB52520E96B01E659';

            tag = argon2id(password, salt, p, T, m, nPasses, secret, associatedData);

            testCase.verifyEqual(blake2impl.bytesToHex(tag), expectedValue);
        end
    end
end
