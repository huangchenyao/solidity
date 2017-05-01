library Math {
    
    // 求int类型的绝对值的函数
    function abs(int num) internal returns (int) {
        if (num >= 0) {
            return num;
        } else {
            return (0 - num);
        }
    }
    
    // 快速幂取余算法
    function pow_mod(int base, int pow, int mod) internal returns (int res) {
        res = 1;
        base = base % mod;
        
        for (; pow != 0; pow >>= 1) {
            if (pow & 1 == 1) {
                res = (base * res) % mod;
            }
            base = (base * base) % mod;
        }
    }
    
    // VC里面的随机数的同余方程，用于产生随机数，xn = rand(xn-1)
    function rand(int x) internal returns (int) {
       return (((x * 214013 + 2531011) >> 16) & 0x7fff);
    }
    
    // 判断一个数是否素数，用的是Miller Rabin算法，进行k次判断，是素数的准确率为 1-(1/4)^k
    // 输入：要判定的数n，判断次数k
    // 输出：bool，是否素数
    function isPrime(int n, int k) internal returns (bool) {
        // 素数表
        int[25] memory primeArr;
        int len;
        if (n < 2047) {
            len = 1;
            primeArr = [int(2), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (n < 1373653) {
            len = 2;
            primeArr = [int(2), 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (n < 9080191) {
            len = 2;
            primeArr = [int(31), 73, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (n < 25326001) {
            len = 3;
            primeArr = [int(2), 3, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (n < 3215031751) {
            len = 3;
            primeArr = [int(2), 3, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (n < 4759123141) {
            len = 3;
            primeArr = [int(2), 7, 61, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (n < 1122004669633) {
            len = 4;
            primeArr = [int(2), 13, 23, 1662803, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (n < 2152302898747) {
            len = 5;
            primeArr = [int(2), 3, 5, 7, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (n < 3474749660383) {
            len = 6;
            primeArr = [int(2), 3, 5, 7, 11, 13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (n < 341550071728321) {
            len = 7;
            primeArr = [int(2), 3, 5, 7, 11, 13, 17, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (n < 3825123056546413051) {
            len = 9;
            primeArr = [int(2), 3, 5, 7, 11, 13, 17, 19, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (n < 318665857834031151167461) {
            len = 12;
            primeArr = [int(2), 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else if (n < 3317044064679887385961981) {
            len = 13;
            primeArr = [int(2), 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        } else {
            len = 25;
            primeArr = [int(2), 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97];
        }
        
        // n大于1时才能讨论是否是素数
        if (n > 1) {
            // 当n为奇数时
            if (n & 1 == 1) {
                if (n == 3 || n == 5) {
                    return true;
                } else if (n % 3 == 0 || n % 5 == 0) {
                    return false;
                } else {
                    // Miller Rabin算法主体
                    // n = 2 ^ s * d
                    int d = n - 1;
                    int s = 0;
                    while (d & 1 != 1) {
                        d >>= 1;
                        ++s;
                    }
                    // loop k
                    int a;
                    int xPre;
                    int j;
                    int randInt = int(now); // 一开始的随机数种子为now，x0 = now
                    for (int i = 0; i < k; ++i) {
                        randInt = rand(randInt);
                        a = primeArr[uint(randInt % len)];
                        // 计算该序列的第一个值：x = a ^ d mod n
                        int x = pow_mod(a, d, n);
                        // 如果该序列的第一个数是1或者n-1，符合上述条件，n可能是素数，转到下一次循环
                        if (x == 1 || x == (n - 1)) {
                            continue;
                        } else {
                            // 遍历剩下的s-1
                            for (j = 1; j < s; ++j) {
                                xPre = x;
                                // 计算下一个值 x = x ^ 2 mod n
                                x = pow_mod(x, 2, n);
                                // 如果这个值是1，但是前面的值不是n-1，n必定是合数
                                if (x == 1 && xPre != (n - 1)) {
                                    return false;
                                }
                                // 如果这个值是n-1，因此下一个值一定是1，n可能是素数，转到下一次循环
                                if (x == (n - 1)) {
                                    break;
                                }
                            }
                            if (x != 1 && j == s) {
                                return false;
                            }
                        }
                    }
                    return true;
                }
            } else {
                if (n == 2) {
                    return true;
                } else {
                    return false;
                }
            }
        } else {
            return false;
        }
    }
    
    // 用于产生n bits的随机数
    // 输入：n bits，种子 seed
    // 输出：n bits的随机数
    function randBit(int n, int seed) internal returns (int num) {
        num = 0;
        int tmp = int(1) << (n - 1);
        if (n > 0 && n < 256) {
            int x = int(seed);
            while (n >= 15) {
                x = rand(x);
                num <<= 15;
                num += x;
                n -= 15;
            }
            x = rand(x);
            num <<= n;
            num += (x >> (15 - n));
            num = num | tmp;
        }
    }
    
    // 用于产生n bits的随机素数
    // 通过调用randBit，与isPrime
    // 输入：n bits，种子 seed
    // 输出：n bits的随机数
    function randPri(int n, int seed) internal returns (int res) {
        res = randBit(n, seed);
        // 1000以内素数表
        int[168] memory prime = [int(2), 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541, 547, 557, 563, 569, 571, 577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641, 643, 647, 653, 659, 661, 673, 677, 683, 691, 701, 709, 719, 727, 733, 739, 743, 751, 757, 761, 769, 773, 787, 797, 809, 811, 821, 823, 827, 829, 839, 853, 857, 859, 863, 877, 881, 883, 887, 907, 911, 919, 929, 937, 941, 947, 953, 967, 971, 977, 983, 991, 997];
        while (true) {
            // 随机出来是偶数，+1
            if (res & 1 == 0) {
                ++res;
            }
            bool mayPri = true;
            // 用素数表进行初步筛选
            for (uint i = 0; i < 168 && res < prime[i]; ++i) {
                if (res % prime[i] == 0) {
                    mayPri = false;
                    break;
                }
            }
            // 筛选后可能是素数，则进行miller rabin判定
            if (mayPri) {
                if (isPrime(res, 1)) {
                    break;
                }
            }
            // 不是素数，+2
            res += 2;
        }
    }

    // 欧几里得算法，a，b已知，求a，b最大公约数
    function gcd(int a, int b) internal returns (int) {
        int t = 0;
        if (a < b) {
            t = a;
            a = b;
            b = t;
        }
        while (b != 0) {
            t = b;
            b = a % b;
            a = t;
        }
        return a;
    }
    
    // 扩展欧几里得算法，a，b已知，求ax + by = gcd(a, b)中的x, y, 以及gcd(a, b)
    function gcdEx(int a, int b) internal returns (int x, int y, int r) {
        if(b == 0) {
            x = 1;
            y = 0;
            r = a;
        }
        else {
            (x, y, r) = gcdEx(b, a % b);
            int t = x;
            x = y;
            y = t - a / b * y;
        }
    }
    
}