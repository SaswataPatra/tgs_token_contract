// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract TokenContract is ERC20Capped, ERC20Burnable {
    address payable public owner;
    uint256 public blockReward;

    constructor(uint256 cap, uint256 reward) ERC20("TokenContract", "TKC") ERC20Capped(cap * (10 ** decimals())) {
        owner = payable(msg.sender);
        _mint(owner, 70000000 * (10 ** decimals()));
        blockReward = reward * (10 ** decimals());
    }
    event TokenTransferred(address indexed from, address indexed to, uint256 value);

      function getTotalSupply() public view returns (uint256) {
        return totalSupply();
    }

    function _mint(address account, uint256 amount) internal virtual override(ERC20Capped, ERC20) {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }

    function _mintMinerReward() internal {
        _mint(block.coinbase, blockReward);
    }

    function _beforeTokenTransfer(address from, address to, uint256 value) internal virtual override {
        if(from != address(0) && to != block.coinbase && block.coinbase != address(0)) {
            _mintMinerReward();
        }
        super._beforeTokenTransfer(from, to, value);
    }

    function setBlockReward(uint256 reward) public onlyOwner {
        blockReward = reward * (10 ** decimals());
    }
    function getBalance(address account) public view returns (uint256) {
        return balanceOf(account);
    }
    function transferTokens(address to, uint256 amount) public {
        _transfer(msg.sender, to, amount);
        emit TokenTransferred(msg.sender, to, amount);
    }
    function approveTokens(address spender, uint256 amount) public {
        _approve(msg.sender, spender, amount);
    }
       function transferFromOneAddressToAnother(address from, address to, uint256 amount) public {
        transferFrom(from, to, amount);
        emit TokenTransferred(from, to, amount);
    }
    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
}

