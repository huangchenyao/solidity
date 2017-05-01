pragma solidity ^0.4.8;

import "BigInt.sol";
import "RSA_int.sol";

library RSA {

    event print(int);

    function setup(int n) internal returns (BigInt.bigint p, BigInt.bigint q) {
        p = BigInt.randPri(n, int(now));
        q = BigInt.randPri(n, p.num[0]);
    }
    
    function keygen(BigInt.bigint p, BigInt.bigint q) internal returns (BigInt.bigint e, BigInt.bigint d, BigInt.bigint n) {
        e = BigInt.fromInt(65537);
        n = BigInt.mul(p, q);
        BigInt.bigint memory eulerN = BigInt.mul(BigInt.sub(p, 1), BigInt.sub(q, 1));
        BigInt.bigint memory k;
        BigInt.bigint memory r;
        (d, k ,r) = BigInt.gcdEx(e, eulerN);
        
        if (BigInt.smaller(d, 0)) {
            d = BigInt.add(d, eulerN);
            k = BigInt.add(k, e);
        }
    }
    
    function encrypt(bytes32[] m, BigInt.bigint e, BigInt.bigint n) internal returns (bytes32[]) {
        if (BigInt.smaller(n, BigInt.fromInt(1 << 255 - 1))) {
            int ei = 0;
            for (uint i = e.len - 1; int(i) >= 0; --i) {
                ei *= 100000000;
                ei += e.num[i];
            }

            int ni = 0;
            for (i = n.len - 1; int(i) >= 0; --i) {
                ni *= 100000000;
                ni += n.num[i];
            }
            
            return RSA_int.encrypt(m, ei, ni);
        } else {
            bytes32[] memory c = new bytes32[](m.length * (n.len + 1) - 1);
            uint len = 0;
            BigInt.bigint memory tmp;
            for (i = 0; i < m.length - 1; ++i) {
                tmp = BigInt.pow_mod(BigInt.fromInt(int(m[i] >> 24 * 8)), e, n);
                for (uint j = 0; j < tmp.len; ++j) {
                    c[len++] = bytes32(tmp.num[j]);
                }
                c[len++] = "-";
            }
            tmp = BigInt.pow_mod(BigInt.fromInt(int(m[i] >> 24 * 8)), e, n);
            for (j = 0; j < tmp.len; ++j) {
                c[len++] = bytes32(tmp.num[j]);
            }
            return c;
        }
    }
    
    function decrypt(bytes32[] c, BigInt.bigint d, BigInt.bigint n) internal returns (bytes32[]) {
        if (BigInt.smaller(n, BigInt.fromInt(1 << 255 - 1))) {
            int di = 0;
            for (uint i = d.len - 1; int(i) >= 0; --i) {
                di *= 100000000;
                di += d.num[i];
            }
            
            int ni = 0;
            for (i = n.len - 1; int(i) >= 0; --i) {
                ni *= 100000000;
                ni += n.num[i];
            }
            
            return RSA_int.decrypt(c, di, ni);
        } else {
            int len = 1;
            for (i = 0; i < c.length; ++i) {
                if (c[i] == bytes32("-")) {
                    ++len;
                }
            }
            bytes32[] memory m = new bytes32[](uint(len));
            BigInt.bigint memory tmp;
            BigInt.init(tmp);
            len = 0;
            for (i = 0; i < c.length; ++i) {
                if (c[i] == bytes32("-")) {
                    m[uint(len++)] = bytes32(BigInt.toStr(BigInt.pow_mod(tmp, d, n))[0]);
                    BigInt.init(tmp);
                } else {
                    tmp.num[tmp.len++] = int64(c[i]);
                }
            }
            m[uint(len++)] = bytes32(BigInt.toStr(BigInt.pow_mod(tmp, d, n))[0]);
            return m;
        }
    }
    
    function sign(bytes32[] m, BigInt.bigint d, BigInt.bigint n) internal returns (bytes32[]) {
        bytes32 hash = sha3(m);
        
        if (BigInt.smaller(n, BigInt.fromInt(1 << 255 - 1))) {
            int di = 0;
            for (uint i = d.len - 1; int(i) >= 0; --i) {
                di *= 100000000;
                di += d.num[i];
            }
            
            int ni = 0;
            for (i = n.len - 1; int(i) >= 0; --i) {
                ni *= 100000000;
                ni += n.num[i];
            }
            
            bytes32[] memory sig = new bytes32[](1);
            sig[0] = RSA_int.sign(m, di, ni);
            return sig;
            
        } else {
            bytes4[] memory sig4;
            sig4 = BigInt.toStr(BigInt.pow_mod(BigInt.fromInt(int(hash)), d, n));
            bytes32[] memory sig32 = new bytes32[](sig4.length);
            for (i = 0; i < sig32.length; ++i) {
                sig32[i] = bytes32(sig4[i]);
            }
            return sig32;
        }
    }
    
    function verify(bytes32[] s, bytes32[] m, BigInt.bigint e, BigInt.bigint n) internal returns (bool) {
        if (BigInt.smaller(n, BigInt.fromInt(1 << 255 - 1))) {
            int ei = 0;
            for (uint i = e.len - 1; int(i) >= 0; --i) {
                ei *= 100000000;
                ei += e.num[i];
            }

            int ni = 0;
            for (i = n.len - 1; int(i) >= 0; --i) {
                ni *= 100000000;
                ni += n.num[i];
            }

            return RSA_int.verify(s[0], m, ei, ni);
        } else {
            bytes32 hash = sha3(m);
            BigInt.bigint memory sig;
            sig.neg = false;
            sig.len = s.length;
            for (i = 0; i < sig.len; ++i) {
                sig.num[i] = int64(s[i] >> 28 * 8);
                print(sig.num[i]);
            }
            return BigInt.equal(BigInt.pow_mod(sig, e, n), BigInt.mod(BigInt.fromInt(int(hash)), n));
        }
    }
    
}