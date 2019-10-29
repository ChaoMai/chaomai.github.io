title: Unix Socket
date: 2016-09-10 13:54:34
categories:
    - socket
---

# Unix Socket

Socket是通信端点的抽象。类似于使用文件访问符访问文件，应用程序使用套接字描述符访问套接字。套接字描述符在unix系统中被当作是一种文件描述符，事实上，许多处理文件描述符的函数**可以用于**处理套接字描述符（如read，write和close）。

# 套接字描述符

```cpp
#include <sys/socket.h>
int socket(int domain, int type, int protocol);
```

1. domain：确定通信的特性，包括地址格式
2. type：确定套接字的类型，进一步确定通信特性
    * SOCK_DGRAM
        * 固定长度，**无连接，不可靠的报文传递**
        * 两个对等进程之间通信时不需要逻辑连接，只需要向对等进程使用的套接字送出一个报文
        * 是自包含报文
    * SOCK_STREAM
        * 有序，可靠，双向，**面向连接的字节流**
        * 要求在交换数据之前，在本地套接字和通信的对等套接字之间建立一个连接
    * SOCK_SECPACKET
        * 类似SOCK_STREAM，但从该套接字得到的是基于报文的服务而不是字节流服务
    * SOCK_RAW
        * 用于直接访问下面的网络层（IP）
        * 应用程序负责构造自己的协议头部（绕过了TCP和UDP）
3. protocol：通常是0，表示为给定的domain和type类型选择的默认协议

# 寻址

## 字节序

字节序是一个处理器架构特性，用于表示像整数这样的大数据类型**内部的字节如何排序**。

little-endian（小端）：最小字节地址出现在最低有效字节（Least Significant Byte）上
big-endian（大端）：最大字节地址出现在最低有效字节（Least Significant Byte）上

要注意的是，在上面两种情况下，MSB总是在**左边**，LSB总是在**右边**。

TCP/IP协议栈使用**大端字节序**。

### 转换

```cpp
#include <arpa/inet.h>

// host 32 bit int -> net 32 bit int
uint32_t htonl(uint32_t hostint32);

// host 16 bit int -> net 16 bit int
uint16_t htons(uint16_t hostint16);

// net 32 bit int -> host 32 bit int
uint32_t ntohl(uint32_t netint32);

// net 16 bit int -> host 16 bit int
uint16_t ntohs(uint16_t netint16);
```

## 地址格式

地址标识一个特定通信域的套接字端点，地址格式与这个**特定套接字的通信域相关**。