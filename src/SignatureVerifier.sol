// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SignatureVerifier {
    using ECDSA for bytes32;

    IERC20 public token;
    address[] public whitelist;
    mapping(address => bool) public hasClaimedTokens;

    uint256 public constant CLAIM_AMOUNT = 100 * 10**18; // 100 tokens

    constructor(address _token, address[] memory _whitelist) {
        token = IERC20(_token);
        whitelist = _whitelist;
    }

    function isWhitelisted(address _address) public view returns (bool) {
        for (uint i = 0; i < whitelist.length; i++) {
            if (whitelist[i] == _address) {
                return true;
            }
        }
        return false;
    }

    function claimTokens(bytes32 messageHash, bytes memory signature) external {
        address signer = messageHash.recover(signature);
        require(isWhitelisted(signer), "Address not whitelisted");
        require(!hasClaimedTokens[signer], "Tokens already claimed");
        
        hasClaimedTokens[signer] = true;
        require(token.transfer(signer, CLAIM_AMOUNT), "Token transfer failed");
    }
}