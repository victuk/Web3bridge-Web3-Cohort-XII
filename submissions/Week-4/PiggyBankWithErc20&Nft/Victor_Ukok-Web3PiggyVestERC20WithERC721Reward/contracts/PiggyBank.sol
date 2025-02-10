// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import {VTokenContract} from "./MyERC20.sol";
import {VNFTContract} from "./MyERC721.sol";

contract Web3PiggyVest {
    uint public id;
    address owner;

    constructor() {
        owner = msg.sender;
    }

    VTokenContract vTokenContract = VTokenContract(owner);

    VNFTContract vNFTContract = VNFTContract(owner);
    

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

    mapping(address => uint) userContributionCount;

    struct balanceAndSavingsReturnStruct {
        uint balance;
        AmountAndTime[] amountAndTime;
    }

    function newDeposit(
        uint _releaseTimeAndDate,
        string calldata _purposeForInvesting,
        uint _amount
    ) external {
        require(msg.sender > address(0), "Invalid address caller");
        require(_amount > 0, "Invalid amount");

        id = id + 1;

        userContributionCount[msg.sender] += 1;


        userBalance[msg.sender] += _amount;
        userSavings[msg.sender].push(
            AmountAndTime({
                id: id,
                savingPurpose: _purposeForInvesting,
                amount: _amount,
                releaseTimeAndDate: _releaseTimeAndDate
            })
        );

        if(userContributionCount[msg.sender] == 2) {
            vNFTContract.safeMint(msg.sender);
        }

        vTokenContract.transferFrom(msg.sender, address(this), _amount);

        emit Deposit(msg.sender, _amount, block.timestamp);
        
    }

    function updateSavings(uint _id, uint _amount) external {
        require(_id != 0, "Savings ID can't be 0");

        bool savingsExists = false;

        userContributionCount[msg.sender] += 1;

        for (uint i = 0; i < userSavings[msg.sender].length; i++) {
            if (userSavings[msg.sender][i].id == _id) {
                savingsExists = true;
                userSavings[msg.sender][i].amount += _amount;
            }
        }

        require(savingsExists, string(abi.encodePacked("Savings with the ID ", _id, " does not exist")));

        if(userContributionCount[msg.sender] == 2) {
            vNFTContract.safeMint(msg.sender);
        }

        vTokenContract.transferFrom(msg.sender, address(this), _amount);

        emit DepositUpdate(msg.sender, _amount, block.timestamp);

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

        require(memoryAmountAndTime.id == 0, "savings not found");

        require(vTokenContract.balanceOf(msg.sender) >= memoryAmountAndTime.amount);

        vTokenContract.transfer(msg.sender, memoryAmountAndTime.amount);

        userSavings[msg.sender][savingsId].amount = 0;

        userBalance[msg.sender] -= memoryAmountAndTime.amount;

        emit Withdrawal(memoryAmountAndTime.amount, block.timestamp);
    }
}