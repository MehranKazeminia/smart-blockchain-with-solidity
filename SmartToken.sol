pragma solidity ^0.5.1;
//  Token creator contract using ERC20
//  & Block Producer Smart Contract (BPSC)
//  By: Somayyeh Gholami & Mehran Kazeminia

contract SmartToken  {
    string name;
    string symbol;
    uint totalValue;
    uint decimals;
    uint priceOfCoin;       
    address owner;
    
//  For example:
//  name = "akacoin" ==> The name of the coins.
//  symbol = "AKA" ==> Symbol of the coins.
//  totalValue = 1000000 ==> Total number of coines.
//  decimals ==> Solidity supports integers but no decimals, so were coded a fixed point arithmetic contract.
//  priceOfToken ==> The price of each Coin is based on Wei(Ether).
//  owner ==> The address of the account that first deploy this contract.

    uint accountCount = 0; // To count the number of accounts.     
    uint trxCount = 0; // To count the number of blocks.
    bool lockTest = false; // For function locking.
    
    struct Account {
        bool account;
        uint accountBalance;
        uint accountOpeningTime;        
        uint lastTimeAsSender;
    }
    mapping(address=>Account) accounts;
    mapping(address => mapping (address => uint)) allowances;     
    address[] membersAddresses; //For storing all addresses.

    struct Trx {
        uint trxTime;        
        uint trxValue;
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
    event NewPaymentBasedWei();
    event Approval(address indexed, address indexed, uint);    
    event Transfer(uint, uint, address indexed, address indexed);
// __________________________________________________________________________________________
// __________________________________________________________________________________________
//  The Owner that first deploys this contract.
            
    constructor(string memory _name, string memory _symbol, uint _totalValue) public {
        require (_totalValue != 0);
        
        name = _name;
        symbol = _symbol;
        totalValue = _totalValue;
        decimals = 0;
        priceOfCoin = 1e12;        
        owner = msg.sender;

        accounts[owner].account = true; // The first address became a member.
        accounts[owner].accountBalance = totalValue;
        accounts[owner].accountOpeningTime = now;
        accounts[owner].lastTimeAsSender = now;
        membersAddresses.push(owner);        

        Trx memory _trx; // The first block or Genesis block. 
        _trx.trxTime = now; // The block registration time         
        _trx.trxValue = totalValue; // Transaction value.
        _trx.senderAddress = owner;  // We considered the sender and recipient equal.      
        _trx.recipientAddress = owner; // We considered the sender and recipient equal.
        trxes.push(_trx);
        
        emit NewAccountWasOpened();
        emit Transfer(_trx.trxTime, _trx.trxValue, _trx.senderAddress, _trx.recipientAddress);
    }
// __________________________________________________________________________________________  
// __________________________________________________________________________________________  
//  The Account Opening.

    function openAccount() public returns(bool) {
        require(! accounts[msg.sender].account); 
        require(msg.sender != address(0));

        accounts[msg.sender].account = true;
        accounts[msg.sender].accountBalance += 0;        
        accounts[msg.sender].accountOpeningTime = now;
        membersAddresses.push(msg.sender);
        accountCount++;
        
        emit NewAccountWasOpened();
        return true;        
    }   
// __________________________________________________________________________________________  
// __________________________________________________________________________________________  
//  Sending Coins.

    function transfer(address recipient, uint amount) public isMember() returns(bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
// __________________________________________________________________________________________
// __________________________________________________________________________________________
//  Approval & Determine for the spender and the amount.

    function approve(address spender, uint amount) public isMember() returns(bool) {
        require((msg.sender != spender) && (amount > 0));
        require((msg.sender != address(0)) && (spender != address(0))); 
        require(accounts[msg.sender].lastTimeAsSender < (now -20));   
        require(amount <= accounts[msg.sender].accountBalance);
        
        allowances[msg.sender][spender] += amount;
        emit Approval(msg.sender, spender, amount);        
        return true;
    }
// __________________________________________________________________________________________ 
// __________________________________________________________________________________________ 
//  Sending coins by the spender.

    function transferFrom(address holder, address recipient, uint amount) public isMember() returns(bool) {
        require(msg.sender != holder);
        require(amount <= allowances[holder][msg.sender]);  

        allowances[holder][msg.sender] -= amount;        
        _transfer(holder, recipient, amount);
        return true;
    }  
// __________________________________________________________________________________________
// __________________________________________________________________________________________
//  Buying Coins from the owner   
    
    function BuyCoins() public payable returns(bool) {
        require((msg.value > 0) && (priceOfCoin > 0));  
        require(msg.value % priceOfCoin == 0);
        
        uint newValue = msg.value / priceOfCoin;
        _transfer(owner, msg.sender, newValue);
        emit NewPaymentBasedWei();
        return true;        
    } 
// __________________________________________________________________________________________
// __________________________________________________________________________________________
//  Paying to owner   
      
    function payToOwner() public returns(bool) {
        require (msg.sender == owner);
        require (address(this).balance > 0);
        
        msg.sender.transfer(address(this).balance);
        return true;        
    }    
// __________________________________________________________________________________________  
// __________________________________________________________________________________________  
//  Block Producer Smart Contract (BPSC)  

    function _transfer(address sender, address recipient, uint amount) internal isLocked() {
        require((sender != recipient) && (amount > 0));
        require((sender != address(0)) && (recipient != address(0)));
        require(accounts[sender].lastTimeAsSender < (now -20));
        
        uint c = accounts[recipient].accountBalance + amount; // Overflow Checking
        require(c > accounts[recipient].accountBalance); // Overflow Checking
        require(amount <= accounts[sender].accountBalance);

        uint totalChecking = 0;
        for (uint i = 0; i <= accountCount; i++) {
            totalChecking += accounts[membersAddresses[i]].accountBalance; 
        }    
        require(totalChecking == totalValue, "System Error.");    
        
        accounts[sender].accountBalance -= amount;
        accounts[sender].lastTimeAsSender = now;
        
        if (accounts[recipient].account) {
            accounts[recipient].accountBalance += amount;
        }
        if (! accounts[recipient].account) { 
            accounts[recipient].account = true;
            accounts[recipient].accountBalance += amount;
            accounts[recipient].accountOpeningTime = now;                
            membersAddresses.push(recipient);
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
   
        emit Transfer(_trx.trxValue, _trx.trxTime, _trx.senderAddress, _trx.recipientAddress);
    }  
// __________________________________________________________________________________________    
// __________________________________________________________________________________________ 
//  This function is of the "view type" and has no computational significance.
    
    function totalSupply() public view returns(string memory _nameOfCoins, string memory _symbolOfCoins, 
        uint _totalNumberOfCoines, uint _priceOfEachCoin, uint _contractBalance, uint _numberOfAccounts, 
        uint _numberOfTransactions) {
            
        _nameOfCoins = name;            
        _symbolOfCoins = symbol;    
        _totalNumberOfCoines = totalValue;            
        _priceOfEachCoin = priceOfCoin;
        _contractBalance = address(this).balance;        
        _numberOfAccounts = accountCount + 1;  
        _numberOfTransactions = trxCount + 1;        
    }
// __________________________________________________________________________________________ 
// __________________________________________________________________________________________ 
//  This function is of the "view type" and has no computational significance.

    function balanceOf(address _account) public view returns(string memory _nameOfCoins, string memory _symbolOfCoins, 
        uint _accountBalance, uint _accountOpeningTime, address _accountAddress) {
        require(accounts[_account].account, "This account has not been opened yet.");
        
        _nameOfCoins = name;            
        _symbolOfCoins = symbol; 
        _accountBalance = accounts[_account].accountBalance; 
        _accountOpeningTime = accounts[_account].accountOpeningTime;
        _accountAddress = _account;
    }
// __________________________________________________________________________________________    
// __________________________________________________________________________________________   
//  This function is of the "view type" and has no computational significance.

    function myAccountBalance() public view isMember() returns(string memory _nameOfCoins, string memory _symbolOfCoins, 
        uint _yourAccountBalance, uint _accountOpeningTime, address _yourAddress) {
        
        _nameOfCoins = name;            
        _symbolOfCoins = symbol; 
        _yourAccountBalance = accounts[msg.sender].accountBalance; 
        _accountOpeningTime = accounts[msg.sender].accountOpeningTime;
        _yourAddress = msg.sender;
    }
// __________________________________________________________________________________________    
// __________________________________________________________________________________________   
//  This function is of the "view type" and has no computational significance.

    function allowance(address holder, address spender) public view returns(uint _remaining) {
        _remaining = allowances[holder][spender];
    }
// __________________________________________________________________________________________ 
// __________________________________________________________________________________________ 
    
}

