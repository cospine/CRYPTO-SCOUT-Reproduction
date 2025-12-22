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
├── dynamic_analysis/       
│    └── logs/               
│        ├── p3_stolen_report.txt
│        └── p4_inconsistent_report.txt
└── Executable/
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
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装 Git, Curl, Python3
sudo apt install -y git curl python3 python3-pip

# 安装 Node.js (用于安装 Ganache 和 Solc)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# 安装 Docker
sudo apt install -y docker.io

# 启动并设置自启
sudo systemctl start docker
sudo systemctl enable docker

# 将当前用户加入 Docker 组 (避免每次输 sudo)
sudo usermod -aG docker $USER

# 重启后验证：
docker --version

# 安装 Ganache CLI (本地以太坊模拟器)
sudo npm install -g ganache-cli

# 安装 Solidity 编译器 (我们要安装旧版 0.4.24，因为论文中很多案例是旧代码)
sudo npm install -g solc@0.4.24
```

## 🚀 安装与构建
我们使用 Docker 来封装 CRYPTO-SCOUT 的运行环境（包含 Python 依赖、Z3 求解器等）。
```
# 克隆仓库
git clone https://github.com/xxki-workstation/Executable.git
cd Executable

# 检查关键的大文件是否存在 (ethereum.7z)
ls -lh ethereum.7z 

# 构建 Docker 镜像 (这一步需要一些时间)
docker build -t crypto_scout:v2.0 .
```

## 🔬 复现指南:核心功能检测
所有复现实验均在本地环境中完成，分为 静态分析 和 动态分析 两个阶段。
### 第一阶段：静态分析复现 (Static Analysis)
此阶段验证工具在没有源码的情况下，仅通过字节码识别逻辑漏洞（P1/P2）和复杂存储结构（S2）的能力。
#### 1. 启动容器并挂载数据将本地的 reproduction/bytecode 目录挂载到容器内的 /share 目录：
```
cd ~/reproduction
docker run -v $(pwd)/bytecode:/share -it crypto_scout:v2.0 /bin/bash
```
#### 2. 复现 P1: Fake Deposit (假充值) 与检测能力验证
目标：验证工具对逻辑漏洞的检测能力，覆盖 Fake Deposit (P1) 及 Fake Notification (P2) 检测模块。

合约源码：见 reproduction/contracts/FakeDeposit.sol。

运行命令 (在容器内执行)：
```
OPTION=p BYTECODE_DIR=/share BYTECODE_FILE_NAME=FakeDeposit.hex sh run.sh
```
预期输出：
```
JSON"plugin": {"fake_deposit": true, "fake_notification": false}
```

结果分析：

- fake_deposit: true：证明工具成功复现并检测出了假充值漏洞。

- fake_notification: false：验证了 P2 检测模块已正常加载并运行（准确判断出当前样本不存在假通知漏洞），证明工具具备完整的逻辑漏洞扫描能力。

#### 3. 复现 S2: Nested Mapping (复杂存储模式识别)
目标：验证工具能否识别传统工具无法解析的嵌套映射结构（如 mapping(address => mapping(uint => uint))，即论文中的 NP4 模式）。

合约源码：见 reproduction/contracts/NestedMapping.sol。

运行命令 (在容器内执行)：
```
OPTION=p BYTECODE_DIR=/share BYTECODE_FILE_NAME=NestedMapping.hex sh run.sh
```
预期输出：日志中应包含类似以下的存储访问指纹：
```
CRYPTO-SCOUT: # eve: sha3(Cload(68), sha3(x, 0)) => {0: 'map1->map0'} || ... # [erc1155]
```
工具成功解析了双层 SHA3 哈希计算，并识别出这是 ERC1155 标准的存储模式。

### 第二阶段：动态分析复现 (Dynamic Analysis)
此阶段验证工具通过分析历史交易痕迹（Traces）来检测攻击行为的能力（P3/P4）。
#### 1. 进入容器
```
# 后台启动容器
docker run -tid crypto_scout:v2.0 /bin/bash
#  查看容器 ID
sudo docker ps
# 进入容器
docker exec -it [CONTAINER_ID] /bin/bash
```

#### 2. 复现 P3: Misleading DEX Attacks (DEX 误导攻击)
原理：检测 DEX 账本记录金额 ($B_1$) 与代币合约实际转账金额 ($B_2$) 是否一致。

运行命令：
```
sh plugin.sh -i P3
```

预期输出：
```
0x... stolen depositToken 8.99
0x... stolen withdrawToken 160162.7
```
输出中出现 stolen 或 frozen 关键字，表明工具成功检测到资金被盗或冻结的攻击交易。

#### 3. 复现 P4: Inconsistent transferFrom (授权不一致)
原理：检测 transferFrom 函数是否正确扣除了授权额度 (Allowance)。

运行命令：
```
sh plugin.sh -i P4
```

预期输出：
```
0x..., 1, 1.157920892373161954235709850E+74
```
输出巨大的科学计数法数值（接近 UINT256_MAX），证明检测到了无限授权或溢出漏洞。

## 📊 实验结论
通过上述步骤，我们完整复现了 CRYPTO-SCOUT 论文的核心功能：

- 静态层面：成功识别了自定义的漏洞合约与嵌套映射结构，并验证了多项逻辑漏洞检测模块的有效性。

- 动态层面：成功复现了针对去中心化交易所（DEX）的真实攻击检测。

实验结果与论文描述一致，证明了该工具在智能合约安全审计方面的有效性。

## 🔗 参考资料

Original Repo: https://github.com/xxki-workstation/CRYPTO-SCOUT

Original Executable: https://github.com/xxki-workstation/Executable