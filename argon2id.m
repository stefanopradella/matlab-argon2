function tag = argon2id(P, S, p, T, m, t, K, X)
% argon2id - Compute the tag of P using the Argon2id algorithm
% 
% Syntax: 
%   tag = ARGON2ID(P, S, p, T, m, t, K, X)
%   tag = ARGON2ID(P, S, p, T, m, t)
% 
% Input Arguments
%   P - Message string
%       string | char array | uint8
%   S - Nonce
%       string | char array | uint8
%   p - Parallelism: number of lanes
%       positive integer scalar between 1 and 2^24 - 1
%   T - Tag length in bytes
%       positive integer scalar between 4 and 2^32 - 1
%   m - Memory size in KiB
%       positive integer scalar between 8*p and 2^32 - 1
%   t - Number of passes
%       positive integer scalar between 1 and 2^32 - 1
%   K - Secret value
%       string | char array | uint8
%   X - Associated data
%       string | char array | uint8
% 
% Reference: 
%   https://datatracker.ietf.org/doc/html/rfc9106.html

    arguments
        P   (:, 1)  char                            % Message string
        S   (:, 1)  char                            % Nonce
        p   (1, 1)  double {mustBeInteger}          % Parallelism: number of lanes
        T   (1, 1)  double {mustBeInteger}          % Tag length
        m   (1, 1)  double {mustBeInteger}          % Memory size [KiB]
        t   (1, 1)  double {mustBeInteger}          % Number of passes
        K   (:, 1)  char = []                       % Secret value
        X   (:, 1)  char = []                       % Associated data
    end

    pp      = p;
    tt      = t;
    ll      = numel(P);
    sl      = numel(S);
    kk      = numel(K);
    xx      = numel(X);
    max32   = 2^32 - 1;

    % Input validation
    if ~allbetween(ll, 0, max32)
        error("Message string length must be between 0 and 2^32 - 1")
    end
    if ~allbetween(sl, 8, max32)
        error("Nonce length must be between 8 and 2^32 - 1")
    end
    if ~allbetween(pp, 1, 2^24 - 1)
        error("Parallelism must be between 1 and 2^24 - 1")
    end
    if ~allbetween(T, 4, max32)
        error("Tag length must be between 4 and 2^32 - 1")
    end
    if ~allbetween(m, 8*pp, max32)
        error("Memory size must be between 8*p and 2^32 - 1")
    end
    if ~allbetween(tt, 1, max32)
        error("Number of passes must be between 1 and 2^32 - 1")
    end
    if ~allbetween(kk, 0, max32)
        error("Secret value length must be between 0 and 2^32 - 1")
    end
    if ~allbetween(xx, 0, max32)
        error("Associated data length must be between 0 and 2^32 - 1")
    end

    tag = argon2impl.argon2(P, S, p, T, m, t, 2, K, X);
end
