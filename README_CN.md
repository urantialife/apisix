## APISIX

[![Build Status](https://travis-ci.org/iresty/apisix.svg?branch=master)](https://travis-ci.org/iresty/apisix)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/iresty/apisix/blob/master/LICENSE)

- **QQ 交流群**: 552030619
- [![Gitter](https://badges.gitter.im/apisix/community.svg)](https://gitter.im/apisix/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

## 什么是 APISIX？

APISIX 是一个云原生、高性能、可扩展的微服务 API 网关。

它是基于 OpenResty 和 etcd 来实现，和传统 API 网关相比，APISIX 具备动态路由和插件热加载，特别适合微服务体系下的 API 管理。

## 为什么选择 APISIX？

如果你正在构建网站、移动设备或 IoT（物联网）的应用，那么你可能需要使用 API 网关来处理接口流量。

APISIX 是基于云原生的微服务 API 网关，可以处理传统的南北向流量，也可以处理服务间的东西向流量。

APISIX 通过插件机制，提供动态负载平衡、身份验证、限流限速等功能，并且支持你自己开发的插件。

更多详细的信息，可以查阅[ APISIX 的白皮书](https://www.iresty.com/download/%E4%BC%81%E4%B8%9A%E7%94%A8%E6%88%B7%E5%A6%82%E4%BD%95%E9%80%89%E6%8B%A9%E5%BE%AE%E6%9C%8D%E5%8A%A1%20API%20%E7%BD%91%E5%85%B3.pdf)

![](doc/images/apisix.png)

## 功能

- **云原生**
- **动态负载均衡**
- **支持一致性 hash 的负载均衡**
- **SSL**
- **监控**
- **反向代理**
- **身份认证**
- **Limit-rate**
- **Limit-count**
- **Limit-concurrency**
- **CLI**
- **REST API**
- **集群**
- **可扩展**
- **高性能**
- **自定义插件**
- **健康检查**: TODO
- **缓存**: TODO.
- **管理控制台**: TODO.
- **OAuth2.0**: TODO.
- **ACL**: TODO.
- **Bot detection**: TODO.
- **IP 黑名单**: TODO.

## 安装

APISIX 在以下操作系统中做过安装和运行测试:

| 操作系统     | OpenResty | 状态 |
| ------------ | --------- | ---- |
| CentOS 7     | 1.15.8.1  | √    |
| Ubuntu 18.04 | 1.15.8.1  | √    |
| Debian 9     | 1.15.8.1  | √    |

现在有两种方式来安装: 如果你是 CentOS 7 的系统，推荐使用 RPM 包安装；其他的系统推荐使用 Luarocks 安装。

### 通过 RPM 包安装（CentOS 7）

```shell
sudo yum install yum-utils
sudo yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo
sudo yum install -y openresty etcd
sudo service etcd start

sudo yum install -y https://github.com/iresty/apisix/releases/download/v0.5/apisix-0.5-0.el7.noarch.rpm
```

如果安装成功，就可以参考 [**快速上手**](#快速上手) 来进行体验。如果失败，欢迎反馈给我们。

### 通过 Luarocks 安装

#### 依赖项

APISIX 是基于 [openresty](http://openresty.org/) 之上构建的, 配置数据的存储和分发是通过 [etcd](https://github.com/etcd-io/etcd) 来完成。

我们推荐你使用 [luarocks](https://luarocks.org/) 来安装 APISIX，不同的操作系统发行版本有不同的依赖和安装步骤，具体可以参考: [安装前的依赖](doc/install-dependencies.md)

#### 安装 APISIX

```shell
sudo luarocks install --lua-dir=/usr/local/openresty/luajit apisix
```

如果一切顺利，你会在最后看到这样的信息：

> apisix is now built and installed in /usr (license: Apache License 2.0)

恭喜你，APISIX 已经安装成功了。

## 搭建开发环境

如果你是开发人员，可以通过下面的命令快速搭建本地开发环境。

```shell
git clone git@github.com:iresty/apisix.git
cd apisix
make dev
```

如果一切顺利，你会在最后看到这样的信息：

> Stopping after installing dependencies for apisix

下面是预期的开发环境目录结构：

```shell
$ tree -L 2 -d apisix
apisix
├── bin
├── conf
├── deps                # 依赖的 Lua 和动态库，放在了这里
│   ├── lib64
│   └── share
├── doc
│   └── images
├── lua
│   └── apisix
├── t
│   ├── admin
│   ├── core
│   ├── lib
│   ├── node
│   └── plugin
└── utils
```

`make` 可以辅助我们完成更多其他功能, 比如:

```shell
$ make help
Makefile rules:

    help:         Show Makefile rules.
    dev:          Create a development ENV
    check:        Check Lua srouce code
    init:         Initialize the runtime environment
    run:          Start the apisix server
    stop:         Stop the apisix server
    clean:        Remove generated files
    reload:       Reload the apisix server
    install:      Install the apisix
```

## 快速上手

1. 启动 APISIX

```shell
sudo apisix start
```

2. 测试限流插件

为了方便测试，下面的示例中设置的是 60 秒最多只能有 2 个请求，如果超过就返回 503：

```shell
curl http://127.0.0.1:9080/apisix/admin/routes/1 -X PUT -d '
{
    "uri": "/index.html",
    "plugins": {
        "limit-count": {
            "count": 2,
            "time_window": 60,
            "rejected_code": 503,
            "key": "remote_addr"
        }
    },
    "upstream": {
        "type": "roundrobin",
        "nodes": {
            "39.97.63.215:80": 1
        }
    }
}'
```

```shell
$ curl -i http://127.0.0.1:9080/index.html
HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 13175
Connection: keep-alive
X-RateLimit-Limit: 2
X-RateLimit-Remaining: 1
Server: APISIX web server
Date: Mon, 03 Jun 2019 09:38:32 GMT
Last-Modified: Wed, 24 Apr 2019 00:14:17 GMT
ETag: "5cbfaa59-3377"
Accept-Ranges: bytes

...
```

你可以跟着文档来尝试更多的[插件](doc/plugins-cn.md).

## 性能测试

使用谷歌云的 4 核心服务器来运行 APISIX，QPS 可以达到 60000，同时延时只有 0.5 毫秒。

你可以看出[性能测试文档](doc/benchmark-cn.md)来了解更多详细内容。

## 开发文档

[详细设计文档](doc/architecture-design-cn.md)

## 参与社区

如果你对 APISIX 的开发和使用感兴趣，欢迎加入我们的 QQ 群来交流:

<img src="doc/images/qq-group.png" width="302" height="302">

## 致谢

灵感来自 Kong 和 Orange。
