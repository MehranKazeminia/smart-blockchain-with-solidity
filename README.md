## Read the full description in the following article:

<div class="alert alert-success">
    <h1 align="center"><a href="https://hackernoon.com/how-to-build-a-smart-blockchain-that-prevents-double-spending-a-step-by-step-guide-vw9m33aq">How To Build a Smart Blockchain That Prevents Double-Spending <<< A Step by Step Guide >>> </h1>
</div>

<img src="https://github.com/SomayyehGholami/Smart-Blockchain-with-Solidity/blob/master/imageForArticle/im101.jpg">

# Description:

The **SmartCreator101.sol** file is a smart contract that generates tokens according to the ERC20 standard.

The **SmartCreator102.sol** file is another smart contract that, in addition to generating ERC20 tokens, stores all transaction details and member account details.

In addition, this contract can verify the transaction of its own tokens and does not allow anyone to double-spending. In other words, this contract does not require the services of Ethereium network miners to verify transactions.

The mathematical logic of the codes of this agreement is much stronger than the logic of various consensus mechanisms, and the general ledger of this intelligent agreement is quite reliable.

The **SmartCreator102x.sol** file is the same as the previous contract, except that in the third transaction, it sends the transaction amount twice to the recipient.

This was done simply to simulate double-spending. Of course, we saw that immediately in the fourth transaction, the contract was able to identify the error or fraud and change the balance of all accounts to the correct state.

The **SmartCreator103.sol** file is the final version of this smart contract. This contract has five more functions than the second stage contract, and with these functions, new features have been added to the contract.
