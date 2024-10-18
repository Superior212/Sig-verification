// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";




contract SignatureVerifier {
    using ECDSA for bytes32;

    IERC20 public token;
    mapping(address => bool) public whitelist;
    mapping(address => bool) public hasClaimed;

    constructor(address _token, address[] memory _whitelist) {
        token = IERC20(_token);
        for (uint i = 0; i < _whitelist.length; i++) {
            whitelist[_whitelist[i]] = true;
        }
    }

 function verifyAndClaim(bytes32 messageHash, bytes memory signature) external {
        address signer = messageHash.recover(signature);
        require(whitelist[signer], "Address not whitelisted");
        require(signer == msg.sender, "Signer must be the sender");
        require(!hasClaimed[signer], "Tokens already claimed");

        hasClaimed[signer] = true;
        require(token.transfer(signer, 100 * 10**18), "Token transfer failed");
    }
   
}