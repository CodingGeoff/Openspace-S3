// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "forge-std/console.sol";

contract SigUtils {
    bytes32 internal DOMAIN_SEPARATOR;

    constructor(bytes32 _DOMAIN_SEPARATOR) {
        DOMAIN_SEPARATOR = _DOMAIN_SEPARATOR;
    }

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    // todo:模板修改此处即可
    bytes32 public constant PERMIT_DEPOSIT = keccak256(
            "PermitDeposit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );
    bytes32 public constant PERMIT_WL_TYPEHASH = keccak256(
            "PermitWhitelist(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );
    bytes32 public constant PERMIT_BUY_TYPEHASH = keccak256(
            "PermitBuy(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    struct Permit {
        address owner;
        address spender;
        uint256 value;
        uint256 nonce;
        uint256 deadline;
    }

    // computes the hash of the fully encoded EIP-712 message for the domain, which can be used to recover the signer
    function getDigest(Permit memory _permit, bytes32 typehash)
        public
        view
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            // typehash,
                            _permit.owner,
                            _permit.spender,
                            _permit.value,
                            _permit.nonce,
                            _permit.deadline
                        )
                    )
                )
            );
    }
}