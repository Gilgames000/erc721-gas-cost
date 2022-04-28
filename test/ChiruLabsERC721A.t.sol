// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ChiruLabsERC721A} from "../src/ChiruLabsERC721A.sol";
import {Receiver} from "./doubles/Receiver.sol";
import "forge-std/Test.sol";
import "forge-std/Vm.sol";

contract ChiruLabsERC721ATest is Test {
    using stdStorage for StdStorage;

    ChiruLabsERC721A private nft;

    function setUp() public {
        nft = new ChiruLabsERC721A("TKN", "Token", "baseUri");
    }

    function testFailNoMintPricePaid() public {
        nft.mintTo(address(1));
    }

    function testMintPricePaid() public {
        nft.mintTo{value: 0.08 ether}(address(1));
    }

    function testFailMaxSupplyReached() public {
        uint256 slot = stdstore
            .target(address(nft))
            .sig("currentTokenId()")
            .find();
        bytes32 loc = bytes32(slot);
        bytes32 mockedCurrentTokenId = bytes32(abi.encode(10000));
        vm.store(address(nft), loc, mockedCurrentTokenId);
        nft.mintTo{value: 0.08 ether}(address(1));
    }

    function testFailMintToZeroAddress() public {
        nft.mintTo{value: 0.08 ether}(address(0));
    }

    function testFailUnSafeContractReceiver() public {
        vm.etch(address(1), bytes("mock code"));
        nft.mintTo{value: 0.08 ether}(address(1));
    }

    function testWithdrawalWorksAsOwner() public {
        Receiver receiver = new Receiver();
        address payable payee = payable(address(0x1337));
        uint256 priorPayeeBalance = payee.balance;

        nft.mintTo{value: nft.MINT_PRICE()}(address(receiver));
        assertEq(address(nft).balance, nft.MINT_PRICE());
        uint256 nftBalance = address(nft).balance;

        nft.withdrawPayments(payee);
        assertEq(payee.balance, priorPayeeBalance + nftBalance);
    }

    function testWithdrawalFailsAsNotOwner() public {
        Receiver receiver = new Receiver();

        nft.mintTo{value: nft.MINT_PRICE()}(address(receiver));
        assertEq(address(nft).balance, nft.MINT_PRICE());

        vm.expectRevert("Ownable: caller is not the owner");
        vm.startPrank(address(0xd3ad));
        nft.withdrawPayments(payable(address(0xd3ad)));
        vm.stopPrank();
    }

    function testTransfer() public {
        nft.mintTo{value: 0.08 ether}(address(1));
        vm.prank(address(1));
        nft.transferFrom(address(1), address(2), 1);
    }
}