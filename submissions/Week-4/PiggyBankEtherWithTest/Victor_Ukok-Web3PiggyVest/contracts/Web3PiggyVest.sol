// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Web3PiggyVest {
    uint public id;

    struct AmountAndTime {
        uint id;
        string savingPurpose;
        uint amount;
        uint releaseTimeAndDate;
    }

    event Withdrawal(uint amount, uint when);

    event Deposit(address payer, uint amount, uint when);

    event DepositUpdate(address payer, uint amount, uint when);

    mapping(address => uint) userBalance;

    mapping(address => AmountAndTime[]) userSavings;

    struct balanceAndSavingsReturnStruct {
        uint balance;
        AmountAndTime[] amountAndTime;
    }

    function newDeposit(
        uint _releaseTimeAndDate,
        string calldata _purposeForInvesting
    ) external payable {
        require(msg.sender > address(0), "Invalid address caller");
        require(msg.value > 0, "Invalid amount");
        // require(block.timestamp > _releaseTimeAndDate, "Date must be in the future");

        id = id + 1;
        userBalance[msg.sender] += msg.value;
        userSavings[msg.sender].push(
            AmountAndTime({
                id: id,
                savingPurpose: _purposeForInvesting,
                amount: msg.value,
                releaseTimeAndDate: _releaseTimeAndDate
            })
        );

        emit Deposit(msg.sender, msg.value, block.timestamp);
        
    }

    function updateSavings(uint _id) external payable {
        require(_id != 0, "Savings ID can't be 0");

        bool savingsExists = false;

        for (uint i = 0; i < userSavings[msg.sender].length; i++) {
            if (userSavings[msg.sender][i].id == _id) {
                savingsExists = true;
                userSavings[msg.sender][i].amount += msg.value;
            }
        }

        userBalance[msg.sender] += msg.value;

        require(savingsExists, string(abi.encodePacked("Savings with the ID ", _id, " does not exist")));

        emit DepositUpdate(msg.sender, msg.value, block.timestamp);

    }

    function getMyBalanceAndSavings()
        external
        view
        returns (balanceAndSavingsReturnStruct memory)
    {
        return
            balanceAndSavingsReturnStruct({
                balance: userBalance[msg.sender],
                amountAndTime: userSavings[msg.sender]
            });
    }

    function withdraw(uint _id) public {
        // Uncomment this line, and the import of "hardhat/console.sol", to print a log in your terminal
        // console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp);

        require(_id != 0, "Savings ID can't be 0");

        AmountAndTime memory memoryAmountAndTime = AmountAndTime({
            id: 0,
            amount: 0,
            savingPurpose: "",
            releaseTimeAndDate: 0
        });

        uint savingsId = 0;

        for (uint i = 0; i < userSavings[msg.sender].length; i++) {
            if (userSavings[msg.sender][i].id == _id) {
                memoryAmountAndTime = userSavings[msg.sender][i];
                savingsId = i;
            }
        }

        require(memoryAmountAndTime.id != 0, "savings not found");

        require(block.timestamp <= memoryAmountAndTime.releaseTimeAndDate, "The withdrawal date and time has not reached yet");

        (bool success, ) = msg.sender.call{value: memoryAmountAndTime.amount}(
            ""
        );

        require(success, "Saved Successfully");

        userSavings[msg.sender][savingsId].amount = 0;

        userBalance[msg.sender] -= memoryAmountAndTime.amount;

        emit Withdrawal(memoryAmountAndTime.amount, block.timestamp);
    }
}
