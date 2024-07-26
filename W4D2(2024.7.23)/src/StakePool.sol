// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "forge-std/console.sol";
import "./RNTIDO.sol";

contract RNTToken is RNT {
    mapping (address=>uint256) public nonces;
    bytes32 _TYPE_HASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 _DOMAIN_SEPARATOR = keccak256(abi.encodePacked(
        _TYPE_HASH,
        keccak256(bytes("RNT Token")),
        keccak256(bytes("1")),
        nonces[msg.sender]++,
        address(this)
    ));
    function DOMAIN_SEPARATOR() public view returns (bytes32){
        return _DOMAIN_SEPARATOR;
    }
    function permit(
        address holder,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                // keccak256(
                                //     "PermitStake(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                // ),
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
        console.log("allowance(holder, spender):",allowance(holder, spender));
        emit Approval(holder, spender, value);

    }

}
contract esRNTToken is RNTToken {
    // function transfer(address to, uint256 amount) public onlyOwner override returns (bool) {
    //     require(msg.sender == owner);
    //     require(amount <= balanceOf(msg.sender), "Not enough esRNT tokens");
    //     return super.transfer(to, amount);
    // }
    function burn(address user, uint256 amount) public onlyOwner {
        require(amount <= balanceOf(msg.sender), "Not enough esRNT tokens");
        _burn(user, amount);
    }
}


contract StakingContract {
    RNTToken public rntToken;
    esRNTToken public esRntToken;
    uint256 public constant RNT_STAKE_POOL_SUPPLY = 5000000 * 10**18;
    struct LockInfo {
        address user;
        uint256 amount;
        uint256 lockTime;
    }

    struct StakeInfo {
        uint256 staked;
        uint256 unclaimed;
        uint256 lastUpdateTime;
    }

    mapping(address => StakeInfo) public stakeInfos;
    mapping(address => LockInfo[]) public lockInfos;

    uint256 public constant REWARD_FREQUENCE = 86400; // 1 esRNT per RNT per day, 86400 seconds in a day
    uint256 public constant LOCK_PERIOD = 30 * 86400;
    // uint256 public constant LOCK_PERIOD = 30 days * 86400;

    constructor(RNTToken rnt, esRNTToken esRnt) {
        rntToken = rnt;
        esRntToken = esRnt;
    }

    function stake(uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
    // function stake(uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(amount > 0, "Cannot stake 0");
        // require(rntToken.allowance(msg.sender, address(this)) >= amount, "Not enough allowance!!!!!!!!!!");
        rntToken.permit(msg.sender, address(this), amount, deadline, v, r, s);

        StakeInfo storage stakeInfo = stakeInfos[msg.sender];


        rntToken.transferFrom(msg.sender, address(this), amount);

        stakeInfo.unclaimed += stakeInfo.staked * (block.timestamp - stakeInfo.lastUpdateTime) / REWARD_FREQUENCE;
        stakeInfo.staked += amount;
        stakeInfo.lastUpdateTime = block.timestamp;

        console.log("-------------------------!!! user stake !!!----------------------------");
        console.log("Staked amount:", amount);
        console.log("stakeInfo.lastUpdateTime: ", stakeInfo.lastUpdateTime);
        console.log("-----------------------------------------------------------");
        logState(msg.sender);
    }
    function claim(uint256 i) external{
        calculateClaimable(i);
    }

    function unstake(uint256 amount) external {
        StakeInfo storage stakeInfo = stakeInfos[msg.sender];
        require(amount > 0, "Cannot unstake 0");

        require(stakeInfo.staked >= amount, "Insufficient staked amount");

        rntToken.transfer(msg.sender, amount);
        stakeInfo.staked -= amount;
        stakeInfo.lastUpdateTime = block.timestamp;

        console.log("Unstaked:", amount);
        logState(msg.sender);
    }


    function unlock() public{
        calculateUnlock();
    }

    function calculateUnlock() internal returns (uint256) {
        address user = msg.sender;
        StakeInfo storage stakeInfo = stakeInfos[user];

        // if the user stake only once, and unlock, and uncliamed variable would still be 0 by default
        // which can cause mistake when the user want to unlock the exact amount of esRntToken.
        // uint256 amount = stakeInfo.unclaimed;
        uint256 amount = stakeInfo.staked * (block.timestamp - stakeInfo.lastUpdateTime) / REWARD_FREQUENCE;
        stakeInfo.unclaimed = 0;

        lockInfos[msg.sender].push(LockInfo({
            user: msg.sender,
            amount: amount,
            lockTime: block.timestamp
        }));

        esRntToken.transfer(msg.sender, amount);

        console.log("-------------------------UNLOCK: START 30 DAYS----------------------------");
        console.log("Amount:", amount);
        console.log("lockTime:", block.timestamp);
        console.log("-----------------------------------------------------------");
        // logState(msg.sender);
    }

    function calculateClaimable(uint256 i) internal returns (uint256) {
        address user = msg.sender;
        StakeInfo storage stakeInfo = stakeInfos[user];
        uint256 claimable;

        // for (int256 i = uint256(lockInfos[user].length) - 1; i >= 0; i--) {
        LockInfo storage lockInfo = lockInfos[user][uint256(i)];
        uint256 timeElapsed = block.timestamp - lockInfo.lockTime;
        require(lockInfo.amount > 0, "Already claimed");
        console.log("LockInfo timeElapsed:", timeElapsed);
        if (timeElapsed >= LOCK_PERIOD) {
            timeElapsed = LOCK_PERIOD;
            claimable = lockInfo.amount;
            console.log("lockInfo.amount:", lockInfo.amount);
            console.log("calculateClaimable - claimable:", claimable);
            rntToken.transfer(msg.sender, claimable);
            esRntToken.burn(user, lockInfo.amount);
            }
        else {
            timeElapsed = block.timestamp - lockInfo.lockTime;
            claimable = uint256(lockInfo.amount * timeElapsed) / LOCK_PERIOD;
            rntToken.transfer(msg.sender, claimable);
            esRntToken.transfer(msg.sender, claimable);
            console.log("lockInfo.amount:", lockInfo.amount);
            console.log("Claimable:", claimable);
            esRntToken.burn(user, lockInfo.amount);
        }
        lockInfo.amount = 0;
    }

    function logState(address user) internal view {
        StakeInfo storage stakeInfo = stakeInfos[user];
        console.log("\n");
        console.log("___________________________________________________________");
        console.log("Staked:", stakeInfo.staked);
        console.log("Unclaimed:", stakeInfo.unclaimed);
        console.log("Last Update Time:", stakeInfo.lastUpdateTime);
        console.log("___________________________________________________________");
        console.log("\n");
        for (uint256 i = 0; i < lockInfos[user].length; i++) {
            console.log("\n");
            console.log("**************** START lockInfo  index:", i, "************************");
            // console.log("logState - LockInfo:", i);
            LockInfo storage lockInfo = lockInfos[user][i];
            if (lockInfo.amount > 0) {
                console.log("LockInfo - User:", lockInfo.user);
                console.log("Amount:", lockInfo.amount);
                console.log("Lock Time:", lockInfo.lockTime);
            }
            console.log("******************* END lockInfo index:", i, "***************************");
            console.log("\n");
        }

        console.log("___________________________________________________________");
    }
}
