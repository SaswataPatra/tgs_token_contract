// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract TokenContract is ERC20Capped, ERC20Burnable {
    address payable public owner;
    uint256 public blockReward;

    // Constructor for TokenContract
    constructor(uint256 cap, uint256 reward) ERC20("TokenContract", "TKC") ERC20Capped(cap * (10 ** decimals())) {
        owner = payable(msg.sender);
        _mint(owner, 70000000 * (10 ** decimals()));
        blockReward = reward * (10 ** decimals());
    }

    // Event to emit when tokens are transferred
    event TokenTransferred(address indexed from, address indexed to, uint256 value);

    // Function to get the total supply of tokens
    function getTotalSupply() public view returns (uint256) {
        return totalSupply();
    }

    function _mint(address account, uint256 amount) internal virtual override(ERC20Capped, ERC20) {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }

    // Function to mint rewards for miners
    function _mintMinerReward() internal {
        _mint(block.coinbase, blockReward);
    }

    function _beforeTokenTransfer(address from, address to, uint256 value) internal virtual override {
        if(from != address(0) && to != block.coinbase && block.coinbase != address(0)) {
            _mintMinerReward();
        }
        super._beforeTokenTransfer(from, to, value);
    }

    // Function to set the block reward
    function setBlockReward(uint256 reward) public onlyOwner {
        blockReward = reward * (10 ** decimals());
    }

    // Function to get the balance of tokens for a given address
    function getBalance(address account) public view returns (uint256) {
        return balanceOf(account);
    }

    // Function to transfer tokens from the sender's address to another address
    function transferTokens(address to, uint256 amount) public {
        _transfer(msg.sender, to, amount);
        emit TokenTransferred(msg.sender, to, amount);
    }

    // Function to approve a certain amount of tokens to be spent by another address
    function approveTokens(address spender, uint256 amount) public {
        _approve(msg.sender, spender, amount);
    }

    // Function to transfer tokens from one address to another on behalf of a given address
    function transferFromOneAddressToAnother(address from, address to, uint256 amount) public {
        transferFrom(from, to, amount);
        emit TokenTransferred(from, to, amount);
    }

    // Modifier to ensure that only the owner can call certain functions
    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
}
