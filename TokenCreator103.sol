pragma solidity ^0.5.1;
// Token creator contract using ERC20
// & Block Producer Smart Contract (BPSC)
// By: Somayyeh Gholami & Mehran Kazeminia

contract TokenCreator103 {
    string name;
    string symbol;
    uint totalValue;
    uint decimals;
    address owner;  
    
//  For example:
//  name = "akacoin" ==> The name of the coins.
//  symbol = "AKA" ==> Symbol of the coins.
//  totalValue = 1000000 ==> Total number of coines.
//  decimals ==> Solidity supports integers but no decimals, so were coded a fixed point arithmetic contract.
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
    mapping (address => mapping (address => uint)) allowances;    
    address[] accountsAddresses; //For storing all addresses.

    struct Trx {
        uint trxTime;        
        uint trxValue;
        address senderAddress;
        address recipientAddress;
    }  
    Trx[] trxes;
//  ____________________________

    struct Member {
        bool member;
        uint memberBalance;
        }
    mapping(address=>Member) members;
    address[] membersAddresses;  
                
//  ____________________________
    
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
    event Transfer(address indexed, address indexed, uint);
    event Approval(address indexed, address indexed, uint);
    
// __________________________________________________________________________________________
//  The Owner that first deploys this contract.

    constructor(string memory _name, string memory _symbol, uint _totalValue) public {
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

    function totalSupply() public view returns (uint _totalSupply) {
        _totalSupply = totalValue;
    }
// __________________________________________________________________________________________   
//  This function is of the "view type".

    function balanceOf(address _account) public view returns (uint _accountBalance) {
        _accountBalance = accounts[_account].accountBalance;  
    }
// __________________________________________________________________________________________  
//  Sending Coins.

    function transfer(address recipient, uint amount) public isMember() returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;        
    }    
// __________________________________________________________________________________________  
//  This function is of the "view type".

    function allowance(address holder, address spender) public view returns (uint _remaining) {
        _remaining = allowances[holder][spender];
    }
// __________________________________________________________________________________________ 
//  Approval & Determine for the spender and the amount.

    function approve(address spender, uint amount) public isMember() returns(bool) {
        require((msg.sender != spender) && (amount > 0));
        require((msg.sender != address(0)) && (spender != address(0))); 
//      require(accounts[msg.sender].lastTimeAsSender < (now - 20));   
        require(amount <= accounts[msg.sender].accountBalance);
        
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);        
        return true;
    }
// __________________________________________________________________________________________ 
//  Sending coins by the spender.

    function transferFrom(address holder, address recipient, uint amount) public returns(bool) {
        require(amount <= allowances[holder][msg.sender]);  

        allowances[holder][msg.sender] -= amount;        
        _transfer(holder, recipient, amount);
        return true;
    }  
// __________________________________________________________________________________________    
//  Block Producer Smart Contract (BPSC)  

    function _transfer(address sender, address recipient, uint amount) internal isLocked() {
        require((sender != recipient) && (amount > 0));
        require((sender != address(0)) && (recipient != address(0)));
//      require(accounts[sender].lastTimeAsSender < (now - 20));
//      _______________________

        uint totalChecking = 0;
        for (uint i = 0; i <= accountCount; i++) {
            totalChecking += accounts[accountsAddresses[i]].accountBalance; 
        } 
        if (totalChecking != totalValue) {
            members[owner].member = true;
            members[owner].memberBalance = totalValue;
            membersAddresses.push(owner); 
            
            uint memberCount = 0;
            for (uint j = 1; j <= trxCount; j++) {
                if (! members[trxes[j].recipientAddress].member) {
                    members[trxes[j].recipientAddress].member = true;
                    membersAddresses.push(trxes[j].recipientAddress);
                    memberCount++;
                }
                if ((trxes[j].trxValue) <= (members[trxes[j].senderAddress].memberBalance)) {
                    members[trxes[j].senderAddress].memberBalance -= trxes[j].trxValue;
                    members[trxes[j].recipientAddress].memberBalance += trxes[j].trxValue;
                }
            }    
            uint checking = 0;
            for (uint k = 0; k <= memberCount; k++) {
                checking += members[membersAddresses[k]].memberBalance;                     
            }
            if ((checking == totalValue) && (memberCount == accountCount)) { 
                for (uint m = 0; m <= memberCount; m++) {
                    accounts[accountsAddresses[m]].accountBalance = members[membersAddresses[m]].memberBalance;
                    members[trxes[m].recipientAddress].member = false;
                    members[membersAddresses[m]].memberBalance = 0;
                    memberCount = 0;
                }    
            }
        } 
//      _______________________

        uint c = accounts[recipient].accountBalance + amount; // Overflow Checking
        require(c > accounts[recipient].accountBalance); // Overflow Checking
        require(amount <= accounts[sender].accountBalance);

        accounts[sender].accountBalance -= amount;
        accounts[sender].lastTimeAsSender = now;
        
        if (accounts[recipient].account) {
            accounts[recipient].accountBalance += amount;
        }
        
        if (! accounts[recipient].account) { 
            accounts[recipient].account = true;
            accounts[recipient].accountBalance += amount;
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



