pragma solidity ^0.5.1;
// Token creator contract using ERC20
// By: Somayyeh Gholami & Mehran Kazeminia

contract SmartCreator101  {
    string name;
    string symbol;
    uint256 totalValue;
    uint8 decimals;
    address owner;    
    
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowances;

    event Transfer(address indexed, address indexed, uint256);
    event Approval(address indexed, address indexed, uint256);
// __________________________________________________________________________________________
//  The Owner that first deploys this contract.
      
    constructor(string memory _name, string memory _symbol, uint256 _totalValue) public {
        require((msg.sender != address(0)) && (_totalValue > 0));   
        
        name = _name;
        symbol = _symbol;
        totalValue = _totalValue;
        decimals = 0;
        owner = msg.sender;

//      For example:
//      name = "AKA Token" ==> The name of the coins.
//      symbol = "AKA" ==> Symbol of the coins.
//      totalValue = 1000000 ==> Total number of coins.
//      decimals = 0 ==> Solidity supports integers but no decimals, so were coded a fixed point arithmetic contract.
//      owner ==> The address of the account that first deploy this contract.            
        
        balances[owner] = totalValue;
    }
// __________________________________________________________________________________________    
//  Total number of coins | This function is of the "view type".

    function totalSupply() public view returns (uint256 _totalSupply) {
        _totalSupply = totalValue;
    }
// __________________________________________________________________________________________   
//  Balance an account | This function is of the "view type".

    function balanceOf(address _account) public view returns (uint256 _accountBalance) {
        _accountBalance = balances[_account]; 
    }
// __________________________________________________________________________________________
//  Sending coins.

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;        
    }   
// __________________________________________________________________________________________  
//  The amount of allowance | This function is of the "view type".

    function allowance(address holder, address spender) public view returns (uint256 _remaining) {
        _remaining = allowances[holder][spender];
    }
// __________________________________________________________________________________________ 
//  Approval & Determine for the spender and the amount.

    function approve(address spender, uint256 amount) public returns (bool) {
        require((msg.sender != spender ) && (amount > 0));
        require((msg.sender != address(0)) && (spender != address(0))); 
        require(amount <= balances[msg.sender]);
        
        allowances[msg.sender][spender] = amount; 
        emit Approval(msg.sender, spender, amount);        
        return true;
    }
// __________________________________________________________________________________________ 
//  Sending coins by the spender.

    function transferFrom(address holder, address recipient, uint256 amount) public returns(bool) {
        require(amount <= allowances[holder][msg.sender]);  

        allowances[holder][msg.sender] -= amount;        
        _transfer(holder, recipient, amount);
        return true;
    } 
// __________________________________________________________________________________________    
//  Transfer function | "Internal type".

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require((sender != recipient) && (amount > 0));
        require((sender != address(0)) && (recipient != address(0)));
        require(amount <= balances[sender]);

        balances[sender] -= amount;
        balances[recipient] = add(balances[recipient], amount);

        emit Transfer(sender, recipient, amount);       
    }  
// __________________________________________________________________________________________ 
//  Overflow Checking | This function is of the "pure type". 

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
// __________________________________________________________________________________________ 

} 
