// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import "forge-std/console.sol";
import "./Sigutils.sol";

contract GeoToken is ERC20("GeoToken", "GEO") {
    mapping (address=>uint256) public nonces;
    bytes32 _TYPE_HASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 _DOMAIN_SEPARATOR = keccak256(abi.encodePacked(
        _TYPE_HASH,
        keccak256(bytes("GeoToken")),
        keccak256(bytes("1")),
        nonces[msg.sender]++,
        address(this)
    ));
    function DOMAIN_SEPARATOR() public view returns (bytes32){
        return _DOMAIN_SEPARATOR;
    }
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
        console.log("mint:", to, amount);
    }
    function permitDeposit(
        address holder,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "PermitDeposit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                holder,
                                spender,
                                value,
                                nonces[holder]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == holder, "INVALID_SIGNER");
            _approve(holder, spender, value);
        }
    }

    function permitWhistlist(
        address holder,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "PermitWhistlist(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                holder,
                                spender,
                                value,
                                nonces[holder]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == holder, "INVALID_SIGNER");
            _approve(holder, spender, value);
        }
    }
    function permitBuy(
        address holder,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "PermitBuy(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                holder,
                                spender,
                                value,
                                nonces[holder]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );
            require(recoveredAddress != address(0) && recoveredAddress == holder, "INVALID_SIGNER");
            // todo: any differences?
            // allowance[holder][spender]=value;
            _approve(holder, spender, value);
        }
        console.log("allowance(holder, spender):",allowance(holder, spender));
        emit Approval(holder, spender, value);
    }
}


