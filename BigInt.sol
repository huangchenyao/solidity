pragma solidity ^0.4.8;

import "Math.sol";

library BigInt {
    
    /*
    本来考虑用的是int类型，即int256作为大数的num的，但是发现进制会太长，
    除法那里耗费太多，所以折中考虑，用int64来表示大数的一位，大数的一位
    实际上是32bit，但是用64bit的来存储，是方便乘法计算，这些进制方面的问题
    以后再改进也可以
    */

    int64 constant base = 100000000; // 大数的进制
    
    struct bigint {
        int64[50] num; // 32bit * 50 = 1600 bit
        uint len; // 大数的当前长度
        bool neg; // 是否为负数，负数为真，正数为假
    }
    
    event print(int);

    // 初始化大数的结构，模拟c++里面的memset()
    function init(bigint bi) internal {
        for (uint i = 0; i < 50; ++i) {
            bi.num[i] = 0;
        }
        bi.len = 0;
        bi.neg = false;
    }
    
    // 把int转化为大数类型
    function fromInt(int num) internal returns (bigint res) {
        init(res);
        res.neg = (num < 0);
        
        if (num == 0) {
            res.num[0] = 0;
            res.len = 1;
        }
        
        int tmp = Math.abs(num);
        while (tmp != 0) {
            res.num[res.len++] = int64(tmp % base);
            tmp /= base;
        }
    }
    
    // 把大数类型转化为字符串输出进行观察，但是string不知道怎么用，就先用bytes4
    function toStr(bigint bn) internal returns (bytes4[] str) {
        uint len = bn.len;
        if (bn.neg) {
            ++len;
        }
        str = new bytes4[](len);
        
        len = 0;
        if (bn.neg) {
            str[len++] = bytes4(45);
        }
        
        for (uint i = 0; i < bn.len; ++i) {
            str[len++] = bytes4(bn.num[i]);
        }
    }
    
    // deep copy
    function copy(bigint bn) internal returns (bigint res) {
        init(res);
        res.neg = bn.neg;
        res.len = bn.len;
        for (uint i = 0; i < bn.len; ++i) {
            res.num[i] = bn.num[i];
        }
    }
    
    function abs(bigint bn) internal returns (bigint res) {
        res.len = bn.len;
        for (uint i = 0; i < bn.len; ++i) {
            res.num[i] = bn.num[i];
        }
        if (bn.neg) {
            res.neg = !bn.neg;
        } else {
            res.neg = bn.neg;
        }
    }
    
    function xor(bool a, bool b) internal returns (bool) {
        if (a && b || !a && !b) {
            return false;
        } else {
            return true;
        }
    }
    
    function left1(bigint a) internal returns (bigint res) {
        int64 carry = 0;
        for (uint i = 0; i < a.len; ++i) {
            a.num[i] <<= 1;
            a.num[i] += carry;
            if (a.num[i] >= base) {
                a.num[i] -= base;
                carry = 1;
            } else {
                carry = 0;
            }
        }
        if (carry == 1) {
            a.num[a.len++] = 1;
        }
        res = a;
    }
    
    // 右移1位
    function right1(bigint a) internal returns (bigint res) {
        for (uint i = a.len - 1; int(i) > 0; --i) {
            a.num[i - 1] += base * (a.num[i] & 1);
            a.num[i] >>= 1;
        }
        a.num[0] >>= 1;
        // 清除高位的0
        for (i = a.len - 1; int(i) > 0 && a.num[i] == 0; --i) {
            --a.len;
        }
        res = a;
    }
    
    // 取bigint的n到m位（高位）最低位0，例如1111 2222 3333 4444 5555 6666，取1到2位，即2222 3333
    function subNum(bigint a, uint n, uint m) internal returns (bigint res) {
        init(res);
        if (int(m) < int(n)) {
            res = fromInt(0);
        } else {
            res.len = m - n + 1;
            res.neg = a.neg;
            for (uint i = 0; i < res.len; ++i) {
                res.num[i] = a.num[a.len - (res.len - i) - n];
            }
        }
    }
    
    // calc function
    function add(bigint a, bigint b) internal returns (bigint res) {
        init(res);
        if (a.neg == b.neg) {
            res.neg = a.neg;
            uint len = a.len > b.len ?a.len: b.len;
            int64 carry = 0;
            for (uint i = 0; i < len; ++i) {
                res.num[i] = a.num[i] + b.num[i] + carry;
                if (res.num[i] >= base) {
                    res.num[i] -= base;
                    carry = 1;
                } else {
                    carry = 0;
                }
                //print(res.num[i]);
            }
            if (carry == 1) {
                res.num[i++] += carry;
            }
            res.len = i;
        } else if (!a.neg && b.neg) {
            res = sub(a, abs(b));
        } else {
            res = sub(b, abs(a));
        }
    }
    
    function add(bigint a, int b) internal returns (bigint res) {
        res = add(a, fromInt(b));
    }
    
    function add(int a, bigint b) internal returns (bigint res) {
        res = add(fromInt(a), b);
    }
    
    function sub(bigint a, bigint b) internal returns (bigint res) {
        init(res);
        // 同号时
        if (a.neg == b.neg) {
            res.neg = a.neg;
            uint len = a.len > b.len? a.len: b.len;
            int64 carry = 0;
            // 被减数绝对值大于减数绝对值时，直接相减
            if (bigger(abs(a), abs(b)) || equal(abs(a), abs(b))) {
                for (uint i = 0; i < len; ++i) {
                    res.num[i] = a.num[i] - b.num[i] - carry;
                    
                    if (res.num[i] < 0) {
                        res.num[i] += base;
                        carry = 1;
                    } else {
                        carry = 0;
                    }            
                }
                res.len = i;
                // 清除高位的0
                for (i = res.len - 1; i > 0 && res.num[i] == 0; --i) {
                    --res.len;
                }
            } else { // 减数绝对值大于被减数绝对值，用减数减去被减数再取负
                res = sub(b, a);
                res.neg = !res.neg;
            }
        } else if (!a.neg && b.neg) {
            res = add(a, abs(b));
        } else {
            res = add(abs(a), b);
            res.neg = true;
        }
    }
    
    function sub(bigint a, int b) internal returns (bigint res) {
        res = sub(a, fromInt(b));
    }
    
    function sub(int a, bigint b) internal returns (bigint res) {
        res = sub(fromInt(a), b);
    }
    
    function mul(bigint a, bigint b) internal returns (bigint res) {
        init(res);
        if (equal0(a) || equal0(b)) {
            res = fromInt(0);
        }
        else {
            res.neg = xor(a.neg, b.neg);
            for (uint i = 0; i < a.len; ++i) {
                for (uint j = 0; j < b.len; ++j) {
                    res.num[i + j] += a.num[i] * b.num[j];
                }
                
                for (uint k = 0; k < a.len + b.len; ++k) {
                    if (res.num[k] >= base) {
                        res.num[k + 1] += res.num[k] / base;
                        res.num[k] %= base;
                    }
                    // print(res.num[k]);
                }
            }
            
            for (i = a.len + b.len - 1; res.num[i] == 0; --i) {
            }
            res.len = i + 1;
        }
    }
    
    function mul(bigint a, int b) internal returns (bigint res) {
        res = mul(a, fromInt(b));
    }
    function mul(int a, bigint b) internal returns (bigint res) {
        res = mul(fromInt(a), b);
    }
    
    function div(bigint a, bigint b) internal returns (bigint res) {
        if (equal0(a) || equal0(b) || smaller(abs(a), abs(b))) {
            res = fromInt(0);
        } else {
            init(res);
            uint len = a.len - b.len;
            res.neg = xor(a.neg, b.neg);
            bigint memory tmp = subNum(a, 0, b.len - 2);
            bigint memory abs_b = abs(b);

            uint i = b.len - 1;
            while (int(len) >= 0) {
                tmp = mul(tmp, base);
                tmp = add(tmp, subNum(a, i, i));
                int64 low = 0;
                int64 high = base - 1;
                int64 mid = 0;
                
                while (low <= high) {
                    mid = (low + high) / 2;
                    if (equal(mul(abs_b, mid), tmp) || (smaller(mul(abs_b, mid), tmp) && bigger(mul(abs_b, mid + 1), tmp))) {
                        break;
                    } else if (smaller(mul(abs_b, mid), tmp)) {
                        low = mid + 1;
                    } else {
                        high = mid - 1;
                    }
                }
                
                tmp = sub(tmp, mul(abs_b, mid));
                res.num[len] = mid;
                ++res.len;
                ++i;
                --len;
                
            }
            
            // 清除高位的0
            for (i = res.len - 1; i > 0 && res.num[i] == 0; --i) {
                --res.len;
            }
            
        }
    }
    
    function div(bigint a, int b) internal returns (bigint res) {
        res = div(a, fromInt(b));
    }
    
    function div(int a, bigint b) internal returns (bigint res) {
        res = div(fromInt(a), b);
    }
    
    function mod(bigint a, bigint b) internal returns (bigint res) {
        if (equal0(a) || equal0(b)) {
            res = fromInt(0);
        } else if (smaller(abs(a), abs(b))) {
            res = a;
        }
        else {
            init(res);
            uint len = a.len - b.len;
            res.neg = xor(a.neg, b.neg);
            bigint memory tmp = subNum(a, 0, b.len - 2);
            bigint memory abs_b = abs(b);

            uint i = b.len - 1;
            while (int(len) >= 0) {
                tmp = mul(tmp, base);
                tmp = add(tmp, subNum(a, i, i));
                int64 low = 0;
                int64 high = base - 1;
                int64 mid = 0;
                
                while (low <= high) {
                    mid = (low + high) / 2;
                    if (equal(mul(abs_b, mid), tmp) || (smaller(mul(abs_b, mid), tmp) && bigger(mul(abs_b, mid + 1), tmp))) {
                        break;
                    } else if (smaller(mul(abs_b, mid), tmp)) {
                        low = mid + 1;
                    } else {
                        high = mid - 1;
                    }
                }
                
                tmp = sub(tmp, mul(abs_b, mid));
                //res.num[len] = mid;
                //++res.len;
                ++i;
                --len;
            }
            res = tmp;
        }
    }
    
    function mod(bigint a, int b) internal returns (bigint res) {
        res = mod(a, fromInt(b));
    }
    
    function mod(int a, bigint b) internal returns (bigint res) {
        res = mod(fromInt(a), b);
    }
    
    function pow(bigint a, bigint b) internal returns (bigint res) {
        res = fromInt(1);
        bigint memory base = a;
        
        for (bigint memory p = copy(b); !equal0(p); right1(p)) {
            if (p.num[0] & 1 == 1) {
                res = mul(base, res);
            }
            base = mul(base, base);
        }
    }
    
    function pow(bigint a, int b) internal returns (bigint res) {
        res = pow(a, fromInt(b));
    }
    
    function pow(int a, bigint b) internal returns (bigint res) {
        res = pow(fromInt(a), b);
    }
    
    function pow_mod(bigint a, bigint b, bigint c) internal returns (bigint res) {
        res = fromInt(1);
        bigint memory base = mod(a, c);
        
        for (bigint memory p = copy(b); !equal0(p); right1(p)) {
            if (p.num[0] & 1 == 1) {
                res = mod(mul(base, res), c);
            }
            base = mod(mul(base, base), c);
        }
    }
    
    function pow_mod(bigint a, bigint b, int c) internal returns (bigint res) {
        res = pow_mod(a, b, fromInt(c));
    }
    
    function pow_mod(bigint a, int b, bigint c) internal returns (bigint res) {
        res = pow_mod(a, fromInt(b), c);
    }
    
    function pow_mod(bigint a, int b, int c) internal returns (bigint res) {
        res = pow_mod(a, fromInt(b), fromInt(c));
    }
    
    
    // compare function
    function smaller(bigint a, bigint b) internal returns (bool) {
        if (equal(a, b)) {
            return false;
        }
        // same flag
        if (a.neg == b.neg) {
            // neg num
            if (a.neg) {
                if (a.len > b.len) {
                    return true;
                } else if (a.len < b.len) {
                    return false;
                } else {
                    // same bit
                    for (uint i = a.len - 1; i >= 0; --i) {
                        if (a.num[i] > b.num[i]) {
                            return true;
                        } else if (a.num[i] < b.num[i]) {
                            return false;
                        }
                    }
                }
            } else {
                // pos num
                if (a.len < b.len) {
                    return true;
                } else if (a.len >b.len) {
                    return false;
                } else {
                    // same bit
                    for (i = a.len - 1; i >= 0; --i) {
                        if (a.num[i] < b.num[i]) {
                            return true;
                        } else if (a.num[i] > b.num[i]) {
                            return false;
                        }
                    }
                }
            }
        } else {
            // diff flag
            return a.neg;
        }
        return false;
    }
    
    function smaller(bigint a, int b) internal returns (bool) {
        bigint memory tmp = fromInt(b);
        return smaller(a, tmp);
    }
    
    function smaller(int a, bigint b) internal returns (bool) {
        bigint memory tmp = fromInt(a);
        return smaller(tmp, b);
    }
    
    function bigger(bigint a, bigint b) internal returns (bool) {
        return !smaller(a, b) && !equal(a, b);
    }
    
    function bigger(bigint a, int b) internal returns (bool) {
        bigint memory tmp = fromInt(b);
        return bigger(a, tmp);
    }
    
    function bigger(int a, bigint b) internal returns (bool) {
        bigint memory tmp = fromInt(a);
        return bigger(tmp, b);
    }
    
    function equal(bigint a, bigint b) internal returns (bool) {
        if (a.neg == b.neg && a.len == b.len) {
            for (uint i = 0; i < a.len; ++i) {
                if (a.num[i] != b.num[i]) {
                    return false;
                }
            }
        } else {
            return false;
        }
        return true;
    }
    
    function equal(bigint a, int b) internal returns (bool) {
        bigint memory tmp = fromInt(b);
        return equal(a, tmp);
    }
    
    function equal(int a, bigint b) internal returns (bool) {
        bigint memory tmp = fromInt(a);
        return equal(tmp, b);
    }
    
    function equal0(bigint a) internal returns (bool) {
        if (a.len == 1 && a.num[0] == 0) {
            return true;
        } else {
            return false;
        }
    }
    
    // bigger than 255bit prime
    // 判断一个大数是否素数，用的是Miller Rabin算法
    // 参数k，进行k次判断，是素数的准确率为 1-(1/4)^k
    // 返回bool，是否素数
    function isPrime(bigint n, int k) internal returns (bool) {
        // 
        int[25] memory primeArr;
        int len;
        if (smaller(n, 2047)) {
            len = 1;
            primeArr = [int(2), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (smaller(n, 1373653)) {
            len = 2;
            primeArr = [int(2), 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (smaller(n, 9080191)) {
            len = 2;
            primeArr = [int(31), 73, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (smaller(n, 25326001)) {
            len = 3;
            primeArr = [int(2), 3, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (smaller(n, 3215031751)) {
            len = 3;
            primeArr = [int(2), 3, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (smaller(n, 4759123141)) {
            len = 3;
            primeArr = [int(2), 7, 61, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (smaller(n, 1122004669633)) {
            len = 4;
            primeArr = [int(2), 13, 23, 1662803, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (smaller(n, 2152302898747)) {
            len = 5;
            primeArr = [int(2), 3, 5, 7, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (smaller(n, 3474749660383)) {
            len = 6;
            primeArr = [int(2), 3, 5, 7, 11, 13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (smaller(n, 341550071728321)) {
            len = 7;
            primeArr = [int(2), 3, 5, 7, 11, 13, 17, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (smaller(n, 3825123056546413051)) {
            len = 9;
            primeArr = [int(2), 3, 5, 7, 11, 13, 17, 19, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (smaller(n, 318665857834031151167461)) {
            len = 12;
            primeArr = [int(2), 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (smaller(n, 3317044064679887385961981)) {
            len = 13;
            primeArr = [int(2), 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else {
            len = 25;
            primeArr = [int(2), 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97];
        }
        
        // 
        if (bigger(n, 1)) {
            if (n.num[0] & 1 == 1) {
                if (equal(n, 3) || equal(n, 5)) {
                    return true;
                } else if (equal0(mod(n, 3)) || equal0(mod(n, 5))) {
                    return false;
                } else {
                    // Miller Rabin
                    // n = 2 ^ s * d
                    bigint memory d = sub(n, 1);
                    bigint memory s = fromInt(0);
                    while (d.num[0] & 1 != 1) {
                        right1(d);
                        s = add(s, 1);
                    }
                    // loop k
                    bigint memory a;
                    bigint memory xPre;
                    bigint memory j;
                    int randInt = int(now); // seed
                    for (int i = 0; i < k; ++i) {
                        a = fromInt(0);
                        randInt = Math.rand(randInt);
                        a = fromInt(primeArr[uint(randInt % len)]);
                        // 计算该序列的第一个值：x = a ^ d mod n
                        bigint memory x = pow_mod(a, d, n);
                        // 如果该序列的第一个数是1或者n-1，符合上述条件，n可能是素数，转到下一次循环
                        if (equal(x, 1) || equal(x, sub(n, 1))) {
                            continue;
                        } else {
                            // 遍历剩下的s-1
                            for (j = fromInt(1); smaller(j, s); j = add(j, 1)) {
                                xPre = x;
                                // 计算下一个值 x = x ^ 2 mod n
                                x = pow_mod(x, 2, n);
                                // 如果这个值是1，但是前面的值不是n-1，n必定是合数
                                if (equal(x, 1) && !equal(xPre, sub(n, 1))) {
                                    return false;
                                }
                                // 如果这个值是n-1，因此下一个值一定是1，n可能是素数，转到下一次循环
                                if (equal(x, sub(n, 1))) {
                                    break;
                                }
                            }
                            if (!equal(x, 1) && equal(j, s)) {
                                return false;
                            }
                        }
                    }
                    return true;
                }
            } else {
                if (equal(n, 2)) {
                    return true;
                } else {
                    return false;
                }
            }
        } else {
            return false;
        }
    }
    
    function random(bigint low, bigint high, int seed) internal returns (bigint res) {
        init(res);
        if (smaller(low, high)) {
            int x = Math.rand(seed);
            res.len = uint(x % int(high.len - low.len + 1) + int(low.len));
            for (uint i = 0; i < res.len; ++i) {
                x = Math.randBit(32, x);
                res.num[i] = int32(x);
            }
            while (true) {
                if (smaller(res, low)) {
                    res = left1(res);
                    continue;
                }
                if (bigger(res, high)) {
                    res = right1(res);
                    continue;
                }
                if (bigger(res, low) && smaller(res, high)) {
                    break;
                }
            }
        } else if (equal(low, high)) {
            res = low;
        } else {
            res = fromInt(0);
        }
    }
    
    // 
    function randPri(int n, int seed) internal returns (bigint res) {
        init(res);
        if (n < 256) {
            res = fromInt(Math.randPri(n, seed));
        } else {
            bigint memory lowBi = pow(fromInt(2), n - 1);
            bigint memory highBi = sub(pow(fromInt(2), n), 1);
            res = random(lowBi, highBi, seed);
        }
    }
    
    
    function gcdEx(bigint a, bigint b) internal returns (bigint x, bigint y, bigint r) {
        if(equal0(b)) {
            x = fromInt(1);
            y = fromInt(0);
            r = a;
        }
        else {
            (x, y, r) = gcdEx(b, mod(a, b));
            bigint memory t = x;
            x = y;
            y = sub(t, mul(div(a, b), y));
        }
    }
}