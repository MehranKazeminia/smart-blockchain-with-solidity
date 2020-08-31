pragma solidity ^0.5.1;
// By: Somayyeh Gholami & Mehran Kazeminia

contract CurrencyOffering102 {
    address owner;
    string coineName;
    uint priceOfCoin;    
    uint totalValue;
    uint freeValue;
    uint maxFreeValue;
    uint restFreeValue;

// For example:
// coineName = "AKA Token" ==> The name of the coins.
// priceOfToken = 1e12 ==> The price of each Coin is based on Wei(Ether).
// totalValue = 7200000000 ==> Total number of coines.
// freeValue = 1000 ==> Gift for every account opening.
// maxFreeValue = 200000000 ==> The total amount allowed to give gifts.

    uint private accountCount = 0;       
    uint private trxCount = 0;
    bool lockTest = false;
    
    struct Account {
        bool account;
        uint accountNumber;
        uint accountOpeningTime;
        uint accountBalance;
    }
    mapping(address=>Account) accounts;
    address[] customersAddresses;

    struct Trx {
        uint trxNumber;
        uint trxValue;
        uint trxTime;
        uint senderNumber;
        address senderAddress;
        uint receiverNumber;        
        address receiverAddress;
        uint paymentBasedWei;
    }  
    Trx[] trxes;

    modifier isMember() {
        require (accounts[msg.sender].account);    
        _;
    }
    modifier isLocked() {
        require (! lockTest);
        lockTest = true;
        _;
        lockTest = false;
    }
    event newAccountWasOpened();
    event newPaymentBasedWei();
    event newBlockWasProduced(uint indexed, uint, uint, uint, address indexed, uint, address indexed, uint);
// __________________________________________________________________________________________
      
    constructor(string memory _coineName, uint _priceOfCoin, uint _totalValue, uint _freeValue, uint _maxFreeValue) public {
        owner = msg.sender;
        coineName = _coineName;
        priceOfCoin = _priceOfCoin;
        totalValue = _totalValue;
        freeValue = _freeValue;         
        maxFreeValue = _maxFreeValue;
        restFreeValue = _maxFreeValue;

        
        require (totalValue != 0);
        require (totalValue >= maxFreeValue);
        require (maxFreeValue >= freeValue);
 
        accounts[owner].account = true;
        accounts[owner].accountNumber = 100000;
        accounts[owner].accountOpeningTime = now;        
        accounts[owner].accountBalance = totalValue;
        emit newAccountWasOpened();
 
        Trx memory _trx;         
        _trx.trxNumber = 0;
        _trx.trxValue = totalValue;
        _trx.trxTime = now;
        _trx.senderNumber = 100000;
        _trx.senderAddress = owner;        
        _trx.receiverNumber = 100000;
        _trx.receiverAddress = owner;
        _trx.paymentBasedWei = 0;
        trxes.push(_trx);
        
        emit newBlockWasProduced(_trx.trxNumber, _trx.trxValue, _trx.trxTime, _trx.senderNumber, 
            _trx.senderAddress, _trx.receiverNumber, _trx.receiverAddress, _trx.paymentBasedWei);
    } 
// __________________________________________________________________________________________
     
    function openAccount() public {
        require (! accounts[msg.sender].account);          

        accountCount++;        
        accounts[msg.sender].account = true;
        accounts[msg.sender].accountNumber = 100000 + accountCount;
        accounts[msg.sender].accountOpeningTime = now;
        accounts[msg.sender].accountBalance = 0;
        customersAddresses.push(msg.sender);
        emit newAccountWasOpened();
        
        if ((accounts[owner].accountBalance >= freeValue) && (restFreeValue >= freeValue)) {
            restFreeValue -= freeValue;            
            accounts[owner].accountBalance -= freeValue;
            accounts[msg.sender].accountBalance += freeValue;
        
            trxCount++;           
            Trx memory _trx;   
            _trx.trxNumber = trxCount;
            _trx.trxValue = freeValue;
            _trx.trxTime = now;
            _trx.senderNumber = 100000;
            _trx.senderAddress = owner;            
            _trx.receiverNumber = accounts[msg.sender].accountNumber;
            _trx.receiverAddress = msg.sender;
            _trx.paymentBasedWei = 0;            
            trxes.push(_trx);
            
            emit newBlockWasProduced(_trx.trxNumber, _trx.trxValue, _trx.trxTime, _trx.senderNumber, 
                _trx.senderAddress, _trx.receiverNumber, _trx.receiverAddress, _trx.paymentBasedWei);
        }
    }
// __________________________________________________________________________________________

    function SendCoins(uint _trxValue , address _trxReceiver) public isMember() {
        require (msg.sender != _trxReceiver);
        require (accounts[msg.sender].accountBalance >= _trxValue);

        if (accounts[_trxReceiver].account) {
            accounts[msg.sender].accountBalance -= _trxValue; 
            accounts[_trxReceiver].accountBalance += _trxValue;
        }
        
        if (! accounts[_trxReceiver].account) { 
            accountCount++;
            accounts[_trxReceiver].account = true;
            accounts[_trxReceiver].accountNumber = 100000 + accountCount;
            accounts[_trxReceiver].accountOpeningTime = now;            
            accounts[msg.sender].accountBalance -= _trxValue; 
            accounts[_trxReceiver].accountBalance = _trxValue; 
            customersAddresses.push(_trxReceiver);
            emit newAccountWasOpened();
        }  
        
        trxCount++;           
        Trx memory _trx;   
        _trx.trxNumber = trxCount;
        _trx.trxValue = _trxValue;
        _trx.trxTime = now;
        _trx.senderNumber = accounts[msg.sender].accountNumber;
        _trx.senderAddress = msg.sender;        
        _trx.receiverNumber = accounts[_trxReceiver].accountNumber;        
        _trx.receiverAddress = _trxReceiver;
        _trx.paymentBasedWei = 0;        
        trxes.push(_trx);
        
        emit newBlockWasProduced(_trx.trxNumber, _trx.trxValue, _trx.trxTime, _trx.senderNumber, 
            _trx.senderAddress, _trx.receiverNumber, _trx.receiverAddress, _trx.paymentBasedWei);
    }  
// __________________________________________________________________________________________

    function BuyCoins() public payable {
        uint newValue = msg.value / priceOfCoin;
        
        require (msg.sender != owner);
        require ((msg.value > 0) && (msg.value % priceOfCoin == 0));
        require (accounts[owner].accountBalance >= newValue); 
        
        if (accounts[msg.sender].account) {
            accounts[owner].accountBalance -= newValue; 
            accounts[msg.sender].accountBalance += newValue;
        }
        
        if (! accounts[msg.sender].account) { 
            accountCount++;
            accounts[msg.sender].account = true;
            accounts[msg.sender].accountNumber = 100000 + accountCount;
            accounts[msg.sender].accountOpeningTime = now;            
            accounts[owner].accountBalance -= newValue; 
            accounts[msg.sender].accountBalance = newValue; 
            customersAddresses.push(msg.sender);
            emit newAccountWasOpened();
        }  
        
        trxCount++;           
        Trx memory _trx;   
        _trx.trxNumber = trxCount;
        _trx.trxValue = newValue;
        _trx.trxTime = now;
        _trx.senderNumber = 100000;
        _trx.senderAddress = owner;        
        _trx.receiverNumber = accounts[msg.sender].accountNumber;        
        _trx.receiverAddress = msg.sender;
        _trx.paymentBasedWei = msg.value;
        trxes.push(_trx);
        
        emit newPaymentBasedWei();
        emit newBlockWasProduced(_trx.trxNumber, _trx.trxValue, _trx.trxTime, _trx.senderNumber, 
            _trx.senderAddress, _trx.receiverNumber, _trx.receiverAddress, _trx.paymentBasedWei);
    }          
// __________________________________________________________________________________________

    function payToOwner() public {
        require (msg.sender == owner);
        require (address(this).balance > 0);
        
        msg.sender.transfer(address(this).balance);
    }
// __________________________________________________________________________________________

    function cheakBalance() public view isMember() returns (uint _yourAccountNumber, uint _accountOpeningTime, 
        uint _yourAccountBalance, string memory _nameOfCoins, address _yourAddress) {
        
        _yourAccountNumber = accounts[msg.sender].accountNumber;
        _accountOpeningTime = accounts[msg.sender].accountOpeningTime;
        _yourAccountBalance = accounts[msg.sender].accountBalance; 
        _nameOfCoins = coineName;
        _yourAddress = msg.sender;
    }  
// __________________________________________________________________________________________

    function systemCheking() public view isMember() returns (string memory _nameOfCoins, uint _priceOfEachCoin, 
        uint _TotalNumberOfCoines, uint _ownerBlance, uint _totalCustomerAccountBalance, uint _numberOfAccounts, 
        uint _numberOfTransactions, uint _restOfGifts, uint _contractBalance) {
        
        uint circulatingCurrencies = 0;
        if (accountCount > 0) {
            for (uint i = 0; i < accountCount; i++) {
                circulatingCurrencies += accounts[customersAddresses[i]].accountBalance; 
            }
        }
        _nameOfCoins = coineName;
        _priceOfEachCoin = priceOfCoin;
        _TotalNumberOfCoines = totalValue;
        _ownerBlance = accounts[owner].accountBalance;
        _totalCustomerAccountBalance = circulatingCurrencies;
        _numberOfAccounts = accountCount;  
        _numberOfTransactions = trxCount;
        _restOfGifts = restFreeValue;
        _contractBalance = address(this).balance;
    }  
// __________________________________________________________________________________________ 

    function lastBlock() public view isMember() returns (string memory _nameOfCoins, uint _blockNumber, 
        uint _transactionValue, uint _transactionTime, uint _senderAccountNumber, address _senderAddress, 
        uint _receiverAccountNumber, address _receiverAddress, uint _paymentBasedOnWei) {
        
        _nameOfCoins = coineName;
        _blockNumber = trxCount;
        _transactionValue = trxes[trxCount].trxValue;
        _transactionTime = trxes[trxCount].trxTime; 
        _senderAccountNumber = trxes[trxCount].senderNumber;
        _senderAddress = trxes[trxCount].senderAddress;
        _receiverAccountNumber = trxes[trxCount].receiverNumber;
        _receiverAddress = trxes[trxCount].receiverAddress;
        _paymentBasedOnWei = trxes[trxCount].paymentBasedWei;
    }  
// __________________________________________________________________________________________

    function blockSearching(uint searchNumber) public view isMember() returns (string memory _nameOfCoins, 
        uint _blockNumber, uint _transactionValue, uint _transactionTime, uint _senderAccountNumber, 
        address _senderAddress, uint _receiverAccountNumber, address _receiverAddress, uint _paymentBasedOnWei) {
        require (searchNumber <= trxCount);

        _nameOfCoins = coineName;
        _blockNumber = searchNumber;
        _transactionValue = trxes[searchNumber].trxValue;
        _transactionTime = trxes[searchNumber].trxTime; 
        _senderAccountNumber = trxes[searchNumber].senderNumber;
        _senderAddress = trxes[searchNumber].senderAddress;
        _receiverAccountNumber = trxes[searchNumber].receiverNumber;
        _receiverAddress = trxes[searchNumber].receiverAddress;
        _paymentBasedOnWei = trxes[searchNumber].paymentBasedWei;
    }  
// __________________________________________________________________________________________


}
