## Math.sol
> 主要是一些数学方面的函数的实现

- 绝对值函数
	- abs(int) returns (int)
- 快速幂取余函数
	- pow_mod(int base, int pow, int mod) returns (int res)
	- res = base ^ pow % mod
- 随机数函数
	- rand(int x) returns (int)
	- 采用VC中的方案，x = ((x * 214013 + 2531011) >> 16) & 0x7fff
- Miller Rabin素性测试
	- isPrime(int n, int k) returns (bool)
	- 判断n是否是素数，误判概率不超过 1-(1/4)^k
- 生成n bits的随机数
	- randBit(int n, int seed) returns (int num)
	- seed为随机种子
- 生成n bits的随机素数
	- randPri(int n, int seed) returns (int num)
	- seed为随机种子
- 欧几里得算法
	- gcd(int a, int b) returns (int)
	- 求a, b的最大公约数
- 扩展欧几里得算法
	- gcdEx(int a, int b) returns (int x, int y, int r)
	- 求ax + by = gcd(a, b)中的x, y, 以及r = gcd(a, b)

## BigInt.sol
> 自己实现的一个大数库，提供大数的运算，加、减、乘、除、幂、模、幂模等，主要用于公钥密码学中的算法，进制为100000000，用一个int64表示一位，实际上一位有大约32bits，位数可以自己调节  
> 依赖Math.sol

- 初始化函数
	- init(bigint bi)
	- 类似于memset()，把大数类型中的值全部置为0
- 输入函数
	- fromInt(int num) returns (bigint res)
	- 模拟输入吧，因为solidity里面没有真正意义上的输入输出，只能当成是从int转换为bigint了
- 输出函数
	- toStr(bigint bn) returns (bytes4[] str)
	- 把大数类型转化为字符串输出进行观察
- 深拷贝
	- copy(bigint bn) returns (bigint res)
	- solidity函数传参的类型包括值类型和引用类型，其中，复杂类型，占用空间较大的。在拷贝时占用空间较大。所以考虑通过引用传递。而struct就是，所以有的地方要用深复制函数，不然就会造成混乱。
- 绝对值
	- abs(bigint bn) returns (bigint res)
- 异或
	- xor(bool a, bool b) returns (bool)
	- 在写合约过程中发现solidity好像不支持bool类型的异或^，所以就自己写了个
- 左移一位
	- left1(bigint a) returns (bigint res)
	- 另外写一个左移算法，用以提高效率
	- 这里因为是引用类型，所以a的值也会改变，所以用不用返回值都没所谓
- 右移一位
	- right1(bigint a) returns (bigint res)
	- 另外写一个右移算法，用以提高效率
	- 这里因为是引用类型，所以a的值也会改变，所以用不用返回值都没所谓
- 取n~m位
	- subNum(bigint a, uint n, uint m) returns (bigint res)
	- 取bigint的n到m位（高位）最低位0，例如1111 2222 3333 4444 5555 6666，取1到2位，即2222 3333
	- 除法用到，也是提高效率用的
- 加法
	- add(bigint a, bigint b) returns (bigint res)
	- add(bigint a, int b) returns (bigint res)
	- add(int a, bigint b) returns (bigint res)
- 减法
	- sub(bigint a, bigint b) returns (bigint res)
	- sub(bigint a, int b) returns (bigint res)
	- sub(int a, bigint b) returns (bigint res)
- 乘法
	- mul(bigint a, bigint b) returns (bigint res)
	- mul(bigint a, int b) returns (bigint res)
	- mul(int a, bigint b) returns (bigint res)
	- 模拟10进制竖式计算，并不是二进制下的计算方法
- 除法
	- div(bigint a, bigint b) returns (bigint res)
	- div(bigint a, int b) returns (bigint res)
	- div(int a, bigint b) returns (bigint res)
	- 用减法模拟，用了二分法和取n~m位函数来提高效率，但效率还是不高，待改进
- 幂
	- pow(bigint a, bigint b) returns (bigint res)
	- pow(bigint a, int b) returns (bigint res)
	- pow(int a, bigint b) returns (bigint res)
	- 快速幂，用了右移right1()
- 模
	- mod(bigint a, bigint b) returns (bigint res)
	- mod(bigint a, int b) returns (bigint res)
	- mod(int a, bigint b) returns (bigint res)
	- 同除法，用减法模拟，用了二分法和取n~m位函数来提高效率，但效率还是不高，待改进
- 幂模
	- pow_mod(bigint a, bigint b) returns (bigint res)
	- pow_mod(bigint a, int b) returns (bigint res)
	- pow_mod(int a, bigint b) returns (bigint res)
	- 效率比较低，被取模计算的效率所限制
- 比较函数
	- smaller(bigint a, bigint b) returns (bool)
	- smaller(bigint a, int b) returns (bool)
	- smaller(int a, bigint b) returns (bool)
	- bigger(bigint a, bigint b) returns (bool)
	- bigger(bigint a, int b) returns (bool)
	- bigger(int a, bigint b) returns (bool)
	- equal(bigint a, bigint b) returns (bool)
	- equal(bigint a, int b) returns (bool)
	- equal(int a, bigint b) returns (bool)
	- equal0(bigint a) returns (bool)
	- 常用的比较函数，大于，小于，等于
	- 单独写出来一个等于0的判断，可以提高一点点效率吧
- Miller Rabin素性测试
	- isPrime(bigint n, int k) returns (bool)
	- 判断n是否是素数，误判概率不超过 1-(1/4)^k
	- 由于要多次用到幂模计算，效率比较低
- 随机数
	- random(bigint low, bigint high, int seed) returns (bigint res)
	- 生成[low, high]间的随机数，seed为种子
- n bits随机素数
	- randPri(int n, int seed) returns (bigint res)
	- 利用随机数函数生成[2^(n-1), 2^n-1]的随机数，以及素性测试来生成n bits的随机数
- 扩展欧几里得算法
	- gcdEx(bigint a, bigint b) returns (bigint x, bigint y, bigint r)
	- 扩展欧几里得算法在大数下的实现

## RSA_int.sol
> RSA在int256下，即秘钥长度< 255bits下的实现  
> 依赖Math.sol

- 初始化
	- setup(int n) returns (int p, int q)
	- 产生n bits的随机素数p, q
- 密钥产生
	- keygen(int p, int q) returns (int e, int d, int n)
	- 用p, q产生公钥(e, n)与私钥(d, n)
	- e默认为0x10001即65537，d由扩展欧几里得算法计算得出
- 加密
	- encrypt(bytes32[] m, int e, int n) returns (bytes32[])
	- 分组加密，m分为8bytes一组，来进行加密，输入前要手动分组，这里只对bytes32[] m的高8bytes进行加密，其余数据丢弃
	- c = m ^ e % n
	- 由于n是小于256bits的，所以不用加分隔符，一组明文对应就是一组密文
- 解密
	- decrypt(bytes32[] c, int d, int n) returns (bytes32[])
	- 分组解密，c分为8bytes一组，来进行解密
	- m = c ^ d % n
- 签名
	- sign(bytes32[] m, int d, int n) returns (bytes32)
	- 把m通过sha3进行哈希，变成256bits数据，由于n是小于256bits，所以得出来的签名只有1组bytes32
	- s = hash(m) ^ d % n
- 验证
	- verify(bytes32 s, bytes32[] m, int e, int n) returns (bool)
	- hash(m) % n == s ^ e % n

## RSA.sol
> RSA在大数下的实现
> 依赖BigInt.sol和RSA_int.sol

- 初始化
	- setup(int n) returns (BigInt.bigint p, BigInt.bigint q)
	- 产生n bits的随机素数p, q
	- 当n < 256bits时，调用RSA_int中的setup，以提高效率
	- 当n >= 256bits时，就用BigInt中的函数来实现
- 密钥产生
	- keygen(BigInt.bigint p, BigInt.bigint q) returns (BigInt.bigint e, BigInt.bigint d, BigInt.bigint n)
	- 用p, q产生公钥(e, n)与私钥(d, n)
	- e默认为0x10001即65537，d由扩展欧几里得算法计算得出
- 加密
	- encrypt(bytes32[] m, BigInt.bigint e, BigInt.bigint n) returns (bytes32[])
	- 分组加密，m分为8bytes一组，来进行加密，输入前要手动分组，这里只对bytes32[] m的高8bytes进行加密，其余数据丢弃
	- c = m ^ e % n
	- 当n < 256bits时，调用RSA_int中的encrypt，以提高效率
	- 当n >= 256bits时，调用幂模算法返回的是一个bigint类型（密文），把bigint类型存放到bytes32中，即一个bytes4存到一个bytes32中，每个密文之间用"-"进行分隔
- 解密
	- decrypt(bytes32[] c, int d, int n) returns (bytes32[])
	- 分组解密，c分为8bytes一组，来进行解密
	- m = c ^ d % n
	- 当n < 256bits时，调用RSA_int中的encrypt，以提高效率
	- 当n >= 256bits时，查找"-"分隔，重组每组的密文，然后幂模计算出明文
- 签名
	- sign(bytes32[] m, int d, int n) returns (bytes32)
	- 把m通过sha3进行哈希，变成256bits数据，由于n是小于256bits，所以得出来的签名只有1组bytes32
	- s = hash(m) ^ d % n
	- 当n < 256bits时，调用RSA_int中的sign，以提高效率
	- 当n >= 256bits时，调用幂模算法返回的是一个bigint类型（签名），把bigint类型存放到bytes32中，即一个bytes4存到一个bytes32中
- 验证
	- verify(bytes32 s, bytes32[] m, int e, int n) returns (bool)
	- hash(m) % n == s ^ e % n
	- 当n < 256bits时，调用RSA_int中的encrypt，以提高效率
	- 当n >= 256bits时，重组出签名，然后幂模进行签名的验证

## ElGamal.sol
未实现

## AES.sol
未实现