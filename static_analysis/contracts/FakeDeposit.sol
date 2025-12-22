pragma solidity ^0.4.24;

contract FakeDeposit {
    mapping(address => uint256) public balances;
    event Transfer(address indexed from, address indexed to, uint256 value);

    // 标准 ERC20 transfer 函数
    function transfer(address _to, uint256 _value) public returns (bool success) {
        // 正常逻辑：余额充足
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false; 
        }
    }
}