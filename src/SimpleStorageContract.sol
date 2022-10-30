// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

contract SimpleStorageContract {

    uint256 public value;

    function set(uint256 _value) public {
        value = _value;
    }
}