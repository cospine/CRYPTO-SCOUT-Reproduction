# CRYPTO-SCOUT

- bin：CRYPTO-SCOUT package file
- bytecode：test case
- ethereum.7z: ethereum client
- plugin: P3、P4、P5 plugins
- tools：dependency tools
  - evm_v1.8.15

# Usage

### docker build

```
docker build -t crypto_scout:v2.0 .
```

### static analysis（P1&P2）

```shell
sh dockerrun.sh -p bytecode/test_bytecode
#output:
#{"pattern": {"lang": "solidity", "type": "p1", "erc": "erc20"}, 
# "plugin": {"fake_deposit": false, "fake_notification": false}}
```

#### note:The output is also saved in JSON format

### dynamic analysis（ P3 & P4 & P5 )

**If you want to use P3、P4、P5 , you need to synchronize the transaction data of the Ethereum public chain. But this process takes a lot of disk space and time . So we synchronized part of the transaction data in advance for testing.**

```
docker run -tid crypto_scout:v2.0 /bin/bash
docker exec -it [CRYPTO-SCOUT_container_id] /bin/bash
sh plugin.sh -i [P3/P4/P5]
```

```shell
sh plugin.sh -i P3
# output:
# txhash, dex  ,token ,account,amount,stolen/frozen,withdrawtoken/depoisttoken,money
#0x47ed713bc0025ce652387a58cdbea6b3b3789f45efb76380ca23585281b87197 0xbF29685856FAE1e228878DFB35B280C0adCC3B05 0x5479EF180EcEaa278c964A526df2b83Bd4007505 0x8e9A972d7FFC2Db85d56220AC8877A30A86Be419 stolen depositToken 8.99
# Misleading_dex.xlsx:output data organized the into an excel table
```

```shell
sh plugin.sh -i P4
# token, txHash, numOfTxs, tokenAmount
#0x3E3AaCCB37fD6b0F88ab0Dac429Ac84107e05a97,0xbdd2a6c3754858aa1f1f4c9d0c6e7e4eb48b809b0f2e992ecbd2e3b60c8b4776,1,1.157920892373161954235709850E+74
#0x64148c4492804E38a4c6a037d13994cde3Bfe55C,0x940df9457be2a6f253ad30bf7b172e15af0e3e5dd13c4492dcaf10cbb484f15a,1,1.157920892373161954235709850E+71
# Inconsisten transferFrom().xlsx :output data organized the into an excel table
```

```sh
sh plugin.sh -i P5
# output
# token,txnum,amount
# 0xfe81b2bB25C34Dfb2A023d1378a5f41759973067,3,834.84
# 0xb444208cB0516C150178fCf9a52604BC04A1aCEa,7,85100007.000000004307812352
# Unauthorized Token Buring.xlsx : output data organized the into an excel table
```

#### note：The excel file of the output result is located in the directory /crypto_scout/plugin/
