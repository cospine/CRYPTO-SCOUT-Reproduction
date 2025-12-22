# CRYPTO-SCOUT 论文复现：自动化代币转账识别与安全分析

本项目是 **DeFi 安全期末大作业** 的复现成果。我们复现了顶会论文 **"Automated and Accurate Token Transfer Identification and Its Applications in Cryptocurrency Security" (FSE 2025)** 中提出的 **CRYPTO-SCOUT** 工具。

该工具能够跨语言（Solidity/Vyper）和跨标准（ERC20/721/1155）自动识别代币转账行为，并检测多种恶意合约漏洞。

## 📂 目录结构

```text
Crypto-Scout-Reproduction/
├── README.md               
├── static_analysis/        
│   ├── contracts/          
│   │   ├── FakeDeposit.sol
│   │   └── NestedMapping.sol
│   ├── bytecode/           
│   └── results/            
└── dynamic_analysis/       
    ├── logs/               
    │   ├── p3_stolen_report.txt
    │   └── p4_inconsistent_report.txt
    └── reproduction_notes.md
```

## 🛠 环境配置与依赖
本复现实验基于 Ubuntu 22.04 虚拟机进行，核心工具运行在 Docker 容器中。

宿主机依赖
```
Operating System: Ubuntu 22.04 LTS

Docker: version 24.x or higher

Node.js: v18.x (用于安装 Ganache 和 Solc)

Ganache CLI: v6.12.2 (本地私有链模拟器)

Solidity Compiler: v0.4.24 (用于编译旧版漏洞合约)
```

安装命令
```
Bash

# 1. 更新系统并安装基础工具
sudo apt update && sudo apt install -y git curl python3 python3-pip docker.io

# 2. 启动 Docker 服务
sudo systemctl start docker && sudo systemctl enable docker
sudo usermod -aG docker $USER
# (注意：执行完上述命令后建议重启虚拟机以生效用户组权限)

# 3. 安装 Node.js, Ganache 和 Solc
curl -fsSL [https://deb.nodesource.com/setup_18.x](https://deb.nodesource.com/setup_18.x) | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g ganache-cli
sudo npm install -g solc@0.4.24
```

## 🚀 安装与构建
我们使用 Docker 来封装 CRYPTO-SCOUT 的运行环境（包含 Python 依赖、Z3 求解器等）。
```
Bash

# 1. 克隆官方仓库 (或使用本仓库提供的修改版)
git clone [https://github.com/xxki-workstation/Executable.git](https://github.com/xxki-workstation/Executable.git)
cd Executable

# 2. 检查大文件依赖 (必须包含 ethereum.7z)
ls -lh ethereum.7z

# 3. 构建 Docker 镜像 (耗时约 5-10 分钟)
docker build -t crypto_scout:v2.0 .
```

## 🔬 复现指南:核心功能检测
所有复现实验均在本地环境中完成，分为 静态分析 和 动态分析 两个阶段。
### 第一阶段：静态分析复现 (Static Analysis)
此阶段验证工具在没有源码的情况下，仅通过字节码识别逻辑漏洞（P1）和复杂存储结构（S2）的能力。
#### 1. 启动容器并挂载数据将本地的 reproduction/bytecode 目录挂载到容器内的 /share 目录：
```
Bash
cd ~/reproduction
docker run -v $(pwd)/bytecode:/share -it crypto_scout:v2.0 /bin/bash
```
#### 2. 复现 P1: Fake Deposit (假充值漏洞)
目标：检测合约在余额不足时未抛出异常（Revert）而是返回 false 的漏洞。
合约源码：见 reproduction/contracts/FakeDeposit.sol。
运行命令 (在容器内执行)：
```
Bash
OPTION=p BYTECODE_DIR=/share BYTECODE_FILE_NAME=FakeDeposit.hex sh run.sh
```
预期输出：
```
JSON"plugin": {"fake_deposit": true, "fake_notification": false}
```
结果显示 fake_deposit: true，证明工具成功通过字节码检测出了逻辑漏洞。
#### 3. 复现 S2: Nested Mapping (复杂存储模式识别)
目标：验证工具能否识别传统工具无法解析的嵌套映射结构（如 mapping(address => mapping(uint => uint))，即论文中的 NP4 模式）。
合约源码：见 reproduction/contracts/NestedMapping.sol。
运行命令 (在容器内执行)：
```
Bash
OPTION=p BYTECODE_DIR=/share BYTECODE_FILE_NAME=NestedMapping.hex sh run.sh
```
预期输出：日志中应包含类似以下的存储访问指纹：
```
PlaintextCRYPTO-SCOUT: # eve: sha3(Cload(68), sha3(x, 0)) => {0: 'map1->map0'} || ... # [erc1155]
```
工具成功解析了双层 SHA3 哈希计算，并识别出这是 ERC1155 标准的存储模式。

### 第二阶段：动态分析复现 (Dynamic Analysis)
此阶段验证工具通过分析历史交易痕迹（Traces）来检测攻击行为的能力（P3/P4）。
#### 1. 进入容器
```
Bash
# 后台启动容器
docker run -tid crypto_scout:v2.0 /bin/bash
# 进入容器 (需先通过 docker ps 获取 CONTAINER_ID)
docker exec -it [CONTAINER_ID] /bin/bash
```

#### 2. 复现 P3: Misleading DEX Attacks (DEX 误导攻击)
原理：检测 DEX 账本记录金额 ($B_1$) 与代币合约实际转账金额 ($B_2$) 是否一致。
运行命令：
```
Bash
sh plugin.sh -i P3
预期输出：
Plaintext
0x... stolen depositToken 8.99
0x... stolen withdrawToken 160162.7
输出中出现 stolen 或 frozen 关键字，表明工具成功检测到资金被盗或冻结的攻击交易。
```

#### 3. 复现 P4: Inconsistent transferFrom (授权不一致)
原理：检测 transferFrom 函数是否正确扣除了授权额度 (Allowance)。
运行命令：Bashsh plugin.sh -i P4
预期输出：
```
Plaintext
0x..., 1, 1.157920892373161954235709850E+74
```
输出巨大的科学计数法数值（接近 UINT256_MAX），证明检测到了无限授权或溢出漏洞。

## 📊 实验结论
通过上述步骤，我们完整复现了 CRYPTO-SCOUT 论文的核心功能：

静态层面：成功识别了自定义的漏洞合约与嵌套映射结构。

动态层面：成功复现了针对去中心化交易所（DEX）的真实攻击检测。

实验结果与论文描述一致，证明了该工具在智能合约安全审计方面的有效性。

## 🔗 参考资料

Original Repo: https://github.com/xxki-workstation/CRYPTO-SCOUT