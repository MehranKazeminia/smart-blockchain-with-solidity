pragma solidity ^0.5.1;
// Token creator contract using ERC20
// & Block Producer Smart Contract (BPSC)
// By: Somayyeh Gholami & Mehran Kazeminia

contract TokenCreator104 {
    string name;
    string symbol;
    uint256 totalValue;
    uint128 decimals;
    address owner;  
    
//  For example:
//  name = "akacoin" ==> The name of the coins.
//  symbol = "AKA" ==> Symbol of the coins.
//  totalValue = 1000000 ==> Total number of coines.
//  decimals ==> Solidity supports integers but no decimals, so were coded a fixed point arithmetic contract.
//  owner ==> The address of the account that first deploy this contract.

    uint128 accountCount = 0; // To count the number of accounts.     
    uint128 trxCount = 0; // To count the number of blocks.
    bool lockTest = false; // For function locking.
    
    struct Account {
        bool account;
        uint256 accountBalance;
        uint256 accountOpeningTime;        
        uint256 lastTimeAsSender;
    }
    mapping(address=>Account) accounts;
    mapping (address => mapping (address => uint256)) allowances;    
    address[] accountsAddresses; //For storing all addresses.

    struct Trx {
        uint256 trxTime;        
        uint256 trxValue;
        address senderAddress;
        address recipientAddress;
    }  
    Trx[] trxes;

    modifier isMember() {
        require(accounts[msg.sender].account, "This account has not been opened yet.");    
        _;
    }
    modifier isLocked() {
        require (! lockTest);
        lockTest = true;
        _;
        lockTest = false;
    }
    
    event NewAccountWasOpened();
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

        accounts[owner].account = true; // The first address became a member.
        accounts[owner].accountBalance = totalValue;
        accounts[owner].accountOpeningTime = now;
        accounts[owner].lastTimeAsSender = now;
        accountsAddresses.push(owner);        

        Trx memory _trx; // The first block or Genesis block. 
        _trx.trxTime = now; // The block registration time         
        _trx.trxValue = totalValue; // Transaction value.
        _trx.senderAddress = owner;  // We considered the sender and recipient equal.      
        _trx.recipientAddress = owner; // We considered the sender and recipient equal.
        trxes.push(_trx);
        
        emit NewAccountWasOpened();
        emit Transfer(_trx.senderAddress, _trx.recipientAddress, _trx.trxValue);        
    }
// __________________________________________________________________________________________    
//  This function is of the "view type".

    function totalSupply() public view returns (uint256 _totalSupply) {
        _totalSupply = totalValue;
    }
// __________________________________________________________________________________________   
//  This function is of the "view type".

    function balanceOf(address _account) public view returns (uint256 _accountBalance) {
        _accountBalance = accounts[_account].accountBalance;  
    }
// __________________________________________________________________________________________  
//  Sending Coins.

    function transfer(address recipient, uint256 amount) public isMember() returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;        
    }    
// __________________________________________________________________________________________  
//  This function is of the "view type".

    function allowance(address holder, address spender) public view returns (uint256 _remaining) {
        _remaining = allowances[holder][spender];
    }
// __________________________________________________________________________________________ 
//  Approval & Determine for the spender and the amount.

    function approve(address spender, uint256 amount) public isMember() returns(bool) {
        require((msg.sender != spender) && (amount > 0));
        require((msg.sender != address(0)) && (spender != address(0))); 
        require(amount <= accounts[msg.sender].accountBalance);        
//      require(accounts[msg.sender].lastTimeAsSender < (now - 20));   //               <===
        uint256 dd = allowances[msg.sender][spender] + amount; // Overflow Checking
        require(dd > allowances[msg.sender][spender]); // Overflow Checking

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
//  Transfer function & Block Producer Smart Contract (BPSC)  

    function _transfer(address sender, address recipient, uint256 amount) internal isLocked() {
        require((sender != recipient) && (amount > 0));
        require((sender != address(0)) && (recipient != address(0)));
//      require(accounts[sender].lastTimeAsSender < (now - 20));   //               <===
//      _______________________
//      The main part of (BPSC)

        uint256 totalChecking = 0;
        for (uint128 i = 0; i <= accountCount; i++) {
            uint256 ee = totalChecking + accounts[accountsAddresses[i]].accountBalance; // Overflow Checking
            require(ee >= totalChecking); // Overflow Checking  
            
            totalChecking += accounts[accountsAddresses[i]].accountBalance; 
        } 
        if (totalChecking != totalValue) {
            for (uint128 m = 0; m <= accountCount; m++) {
                accounts[accountsAddresses[m]].accountBalance = 0;
            }
            
            accounts[owner].accountBalance = totalValue;
            for (uint128 j = 1; j <= trxCount; j++) {
                
                if ((trxes[j].trxValue) <= (accounts[trxes[j].senderAddress].accountBalance)) {
                    uint256 ff = accounts[trxes[j].recipientAddress].accountBalance + trxes[j].trxValue; // Overflow Checking
                    require(ff >= accounts[trxes[j].recipientAddress].accountBalance); // Overflow Checking  
                    
                    accounts[trxes[j].senderAddress].accountBalance -= trxes[j].trxValue;
                    accounts[trxes[j].recipientAddress].accountBalance += trxes[j].trxValue;
                }                
            }
            
            totalChecking = 0;
            for (uint128 k = 0; k <= accountCount; k++) {
                uint256 gg = totalChecking + accounts[accountsAddresses[k]].accountBalance; // Overflow Checking
                require(gg >= totalChecking); // Overflow Checking
                
                totalChecking += accounts[accountsAddresses[k]].accountBalance;  
            }   
        }
        
        require(totalChecking == totalValue, "System Error.");
//      _______________________

        uint256 cc = accounts[recipient].accountBalance + amount; // Overflow Checking
        require(cc >= accounts[recipient].accountBalance); // Overflow Checking
        require(amount <= accounts[sender].accountBalance);

        accounts[sender].accountBalance -= amount;
        accounts[sender].lastTimeAsSender = now;
        
        if (accounts[recipient].account) {
            accounts[recipient].accountBalance += amount;
//          accounts[recipient].accountBalance += 1000;   //               <===
            
        }
        
        if (! accounts[recipient].account) { 
            accounts[recipient].account = true;
            accounts[recipient].accountBalance += amount;
//          accounts[recipient].accountBalance += 1000;   //               <===
            accounts[recipient].accountOpeningTime = now;                
            accountsAddresses.push(recipient);
            accountCount++;     
            
            emit NewAccountWasOpened();
        } 
        
        trxCount++;         
        Trx memory _trx; 
        _trx.trxTime = now;        
        _trx.trxValue = amount;
        _trx.senderAddress = sender;        
        _trx.recipientAddress = recipient;
        trxes.push(_trx);
   
        emit Transfer(_trx.senderAddress, _trx.recipientAddress, _trx.trxValue);
    }  
// __________________________________________________________________________________________ 

}


