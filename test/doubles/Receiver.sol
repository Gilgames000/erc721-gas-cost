// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 id,
        bytes calldata data
    ) external returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
