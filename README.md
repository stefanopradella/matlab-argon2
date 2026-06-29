# matlab-argon2

MATLAB-native implementation of the Argon2 password-hashing and key-derivation algorithm based on [RFC 9106](https://datatracker.ietf.org/doc/html/rfc9106.html).
Supports Argon2d, Argon2i, and Argon2id, configurable tag length, memory size, number of passes, parallelism, and optional secret and associated data.

```matlab
tag = argon2id('password', 'somesalt', 1, 32, 8, 1); % 32-byte uint8 tag
tag = argon2i('password', 'somesalt', 1, 32, 8, 1, 'secret', 'data');
```

> **Performance note:** This is currently a pure MATLAB reference-style implementation.
> Algorithm performance is poor with practical Argon2 parameters, and optimization work is in progress.

Tested on MATLAB R2025b. Requires [matlab-blake2](https://codeberg.org/stefanopradella/matlab-blake2) submodule.

License: MIT.

> **Note:** The GitHub repository is a mirror used to publish releases to MATLAB File Exchange.
> For contributions, please open pull requests on the main repo on [Codeberg](https://codeberg.org/stefanopradella/matlab-argon2).
