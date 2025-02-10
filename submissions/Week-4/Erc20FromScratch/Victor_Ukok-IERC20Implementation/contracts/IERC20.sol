// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recepient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender, address, address recepient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to , uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
}