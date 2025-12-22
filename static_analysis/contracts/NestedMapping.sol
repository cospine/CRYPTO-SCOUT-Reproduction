pragma solidity ^0.4.24;

contract NestedMapping {
    // NP4 模式: mapping(address => mapping(uint => uint))
    // 这种双层映射常用于 ERC1155 (账户 -> TokenID -> 余额)
    mapping (address => mapping(uint256 => uint256)) internal balances;

    // 必须定义标准事件，否则会被当作无关变量过滤掉
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    // 模拟标准转账函数
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value) public {
        // 修改发送方余额 (Nested Mapping access 1)
        balances[_from][_id] = balances[_from][_id] - _value;
        
        // 修改接收方余额 (Nested Mapping access 2)
        balances[_to][_id] = balances[_to][_id] + _value;
        
        // 触发标准事件
        emit TransferSingle(msg.sender, _from, _to, _id, _value);
    }
}