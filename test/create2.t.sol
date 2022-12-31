// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

import "forge-std/console.sol";
import "forge-std/Test.sol";

contract ETHHolder {
    uint256 public a = 0;

    function withdraw() public payable {
        a = 5;
        payable(msg.sender).transfer(address(this).balance);
    }
}

contract Tst is Test {
    event logBytes(bytes32 indexed b);

    receive() external payable {}

    //we are deploying exact contract to same address again, this will be reverted
    function testFailDeploy() public {
        address deployer = address(this);
        bytes1 prefix = 0xFF;
        bytes32 salt = keccak256(
            abi.encodePacked(
                "this is a salt, keep it safe if you are going to send ether to the contract"
            )
        );
        bytes memory cc = type(ETHHolder).creationCode; // cc= creation code
        bytes memory x = abi.encodePacked(
            prefix,
            deployer,
            salt,
            keccak256(cc)
        );

        uint256 value = 1 ether;
        address precalculated = address(uint160(uint(keccak256(x)))); //get the address
        payable(precalculated).transfer(value); //send ether
        console.log("sent 1 ether to precalculated address...");

        address ethHolder; //this is going to be address of our contract
        console.log("deploying ETHHolder to save our funds...");

        assembly {
            ethHolder := create2(0, add(cc, 32), mload(cc), salt) //create and return the address
        }

        assembly {
            ethHolder := create2(0, add(cc, 32), mload(cc), salt) //create and return the address
        }

        assertEq(ethHolder, precalculated); // predicted contract and target address are not same anymore, since we 
        //overrided ethHolder, its now set to address(0)
        
        console.log("Precalculated and ethHolder are same! yaay!");

        uint256 fb = address(this).balance; //fb = first balance (ether)
        console.log("withdrawing funds...");
        ETHHolder(precalculated).withdraw(); //now withdraw our funds!
        uint256 sb = address(this).balance; //sb = second balance (ether)
        assertEq(sb - fb, value);
        console.log("withdrawed funds : ", sb - fb);
    }

    //we are deploying exact contract to same address again, this will be reverted
    function testDeploy() public {
        address deployer = address(this);
        bytes1 prefix = 0xFF;
        bytes32 salt = keccak256(
            abi.encodePacked(
                "this is a salt, keep it safe if you are going to send ether to the contract"
            )
        );
        bytes memory cc = type(ETHHolder).creationCode; // cc= creation code
        bytes memory x = abi.encodePacked(
            prefix,
            deployer,
            salt,
            keccak256(cc)
        );

        uint256 value = 1 ether;
        address precalculated = address(uint160(uint(keccak256(x)))); //get the address
        payable(precalculated).transfer(value); //send ether
        console.log("sent 1 ether to precalculated address...");

        address ethHolder; //this is going to be address of our contract
        console.log("deploying ETHHolder to save our funds...");
        assembly {
            ethHolder := create2(0, add(cc, 32), mload(cc), salt) //create and return the address
        }

        assertEq(ethHolder, precalculated); // predicted contract and target address are same!
        console.log("Precalculated and ethHolder are same! yaay!");

        uint256 fb = address(this).balance; //fb = first balance (ether)
        console.log("withdrawing funds...");
        ETHHolder(precalculated).withdraw(); //now withdraw our funds!
        uint256 sb = address(this).balance; //sb = second balance (ether)
        assertEq(sb - fb, value);
        console.log("withdrawed funds : ", sb - fb);
    }
}
