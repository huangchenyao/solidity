pragma solidity ^0.4.8;

import "Math.sol";

library RSA_int {
    
    function setup(int n) internal returns (int p, int q) {
        p = Math.randPri(n, int(now));
        q = Math.randPri(n, p);
    }
    
    function keygen(int p, int q) internal returns (int e, int d, int n) {
        e = 65537;
        n = p * q;
        int eulerN = (p - 1) * (q - 1);
        int k;
        int r;
        (d, k ,r) = Math.gcdEx(e, eulerN);
        
        if (d < 0) {
            d += eulerN;
            k += e;
        }
    }
    
    function encrypt(bytes32[] m, int e, int n) internal returns (bytes32[]) {
        bytes32[] memory c;
        c = new bytes32[] (m.length);
        for (uint i = 0; i < m.length; ++i) {
            c[i] = bytes32(Math.pow_mod(int(m[i] >> 24 * 8), e, n));
        }
        return c;
    }
    
    function decrypt(bytes32[] c, int d, int n) internal returns (bytes32[]) {
        bytes32[] memory m;
        m = new bytes32[] (c.length);
        for (uint i = 0; i < c.length; ++i) {
            m[i] = bytes32(Math.pow_mod(int(c[i]), d, n));
            m[i] <<= 24 * 8;
        }
        return m;
    }
    
    function sign(bytes32[] m, int d, int n) internal returns (bytes32) {
        bytes32 hash = sha3(m);
        return bytes32(Math.pow_mod(int(hash), d, n));
    }
    
    function verify(bytes32 s, bytes32[] m, int e, int n) internal returns (bool) {
        bytes32 hash = sha3(m);
        return ((int(hash) % n) == Math.pow_mod(int(s), e, n));
    }
    
}