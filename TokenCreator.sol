pragma solidity ^0.5.1;
// Token creator contract using ERC20
// By: Somayyeh Gholami & Mehran Kazeminia

contract TokenCreator  {
    string name;
    string symbol;
    uint totalValue;
    uint decimals;
    address owner;    
    
    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowances;

    event Transfer(address indexed, address indexed, uint);
    event Approval(address indexed, address indexed, uint);
// __________________________________________________________________________________________
      
    constructor(string memory _name, string memory _symbol, uint _totalValue) public {
        name = _name;
        symbol = _symbol;
        totalValue = _totalValue;
        decimals = 0;
        owner = msg.sender;

        require (totalValue != 0);
        balances[owner] = totalValue;
    }
// __________________________________________________________________________________________    

    function totalSupply() public view returns (uint _totalSupply) {
        _totalSupply = totalValue;
    }
// __________________________________________________________________________________________   

    function balanceOf(address account) public view returns (uint _accountBalance) {
        _accountBalance = balances[account];        
    }
// __________________________________________________________________________________________  

    function transfer(address recipient, uint amount) public returns (bool) {
        require((recipient != msg.sender) && (amount > 0));   
        require((msg.sender != address(0)) && (recipient != address(0)));
        uint c = balances[recipient] + amount; // Overflow Checking
        require(c > balances[recipient]); // Overflow Checking
        require(amount <= balances[msg.sender]);
        
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        
        emit Transfer(msg.sender, recipient, amount);       
        return true;
    }    
// __________________________________________________________________________________________  

    function allowance(address holder, address spender) public view returns (uint _remaining) {
        _remaining = allowances[holder][spender];
    }
// __________________________________________________________________________________________ 

    function approve(address spender, uint amount) public returns (bool) {
        require((spender != msg.sender) && (amount > 0));
        require((msg.sender != address(0)) && (spender != address(0))); 
        require(amount <= balances[msg.sender]);
        
        allowances[msg.sender][spender] = amount; 
        
        emit Approval(msg.sender, spender, amount);        
        return true;
    }
// __________________________________________________________________________________________ 

    function transferFrom(address holder, address recipient, uint amount) public returns (bool) {
        require((holder != msg.sender) && (amount > 0));
        require((holder != address(0)) && (recipient != address(0)) && (msg.sender != address(0)));
        uint c = balances[recipient] + amount; // Overflow Checking
        require(c > balances[recipient]); // Overflow Checking
        require(amount <= allowances[holder][msg.sender]);
        require(amount <= balances[holder]);  
        
        allowances[holder][msg.sender] -= amount;
        balances[holder] -= amount;
        balances[recipient] += amount;
        
        emit Transfer(holder, recipient, amount);
        return true;
    }            
 // __________________________________________________________________________________________    

}    
