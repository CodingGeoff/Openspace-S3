// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzepplin-contracts/contracts/token/ERC20/IERC20.sol";
import "./IFlashLoanRecipient.sol";

interface IBalancerVault {
    function flashLoan(
        IFlashLoanRecipientBalancer recipient,
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external;
}
