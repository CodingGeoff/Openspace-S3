// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/StakePool.sol";
import "../src/SigUtils.sol";


contract StakingContractTest is Test {

    RNTToken public rntToken;
    esRNTToken public esRntToken;
    StakingContract public stakingContract;
    address public user;
    uint256 public  privateKey;
    uint256 public constant UserInitialRntToken = 100*10**18;
    address public owneruser;
    uint256 public privateKeyowner;

    SigUtils sigUtils;

    function setUp() public {
        (owneruser, privateKeyowner) = makeAddrAndKey("owner");
        (user, privateKey) = makeAddrAndKey("Alice");
        vm.startPrank(owneruser);
        rntToken = new RNTToken();
        esRntToken = new esRNTToken();
        stakingContract = new StakingContract(rntToken, esRntToken);

        // Ensure there are enough tokens for testing
        rntToken.transfer(address(rntToken), 100000*10**18);
        esRntToken.transfer(address(esRntToken), 100000*10**18);
        rntToken.transfer(address(stakingContract), 100000*10**18);
        esRntToken.transfer(address(stakingContract), 100000*10**18);
        rntToken.transfer(user, UserInitialRntToken);

        // rntToken and esRntToken need to be minted by the staking pool (requires admin privileges), then sent to the user's account.
        rntToken.setOwner(address(stakingContract));
        esRntToken.setOwner(address(stakingContract));
        sigUtils = new SigUtils(rntToken.DOMAIN_SEPARATOR());

        vm.label(user, "Alice");
        vm.label(address(owneruser), "THE OWNER");
        vm.label(address(this), "Test Contract");
        vm.label(address(stakingContract), "The Staking Pool Contract");
        vm.label(address(rntToken), "The RNT Token Contract");
        vm.label(address(esRntToken), "The esRNT Token Contract");
        vm.stopPrank();

        console.log("owner of rnt", rntToken.owner());
        console.log("owner of esrnt", esRntToken.owner());
    }

    function testInitialStakeInfo() public view {
        assertEq(esRntToken.owner(), address(stakingContract));
        assertEq(rntToken.balanceOf(user), UserInitialRntToken);
        assertEq(esRntToken.balanceOf(user), 0);
    }

    function testPermit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: user,
            spender: address(stakingContract),
            value: 60 * 10**18,
            nonce: 0,
            deadline: 1 days
        });
        bytes32 typehash = keccak256(
            "PermitStake(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );
        bytes32 digest = sigUtils.getDigest(permit, typehash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        vm.startPrank(user);
        stakingContract.stake(60*10**18, permit.deadline, v, r, s);

        // stakingPool executes transferFrom consuming allowance
        assertEq(rntToken.allowance(user, address(stakingContract)), 0);
        // After signing once, nonces increment, making the original signature invalid
        assertEq(rntToken.nonces(user), 1);
        vm.stopPrank();
        (uint256 staked, uint256 unclaimed, uint256 lastUpdateTime) = stakingContract.stakeInfos(user);
        assertEq(staked, 60*10**18);
    }

    function testPermitMultipleOperations() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: user,
            spender: address(stakingContract),
            value: 60 * 10**18,
            nonce: 0,
            deadline: 1 days
        });
        bytes32 typehash = keccak256(
            "PermitStake(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );
        bytes32 digest = sigUtils.getDigest(permit, typehash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        vm.startPrank(user);
        stakingContract.stake(60*10**18, permit.deadline, v, r, s);

        (uint256 staked, uint256 unclaimed, uint256 lastUpdateTime) = stakingContract.stakeInfos(user);
        assertEq(staked, 60*10**18);
        assertEq(unclaimed, 0);
        assertEq(rntToken.balanceOf(user), 40*10**18);
        assertEq(esRntToken.balanceOf(user), 0);
        assertEq(rntToken.balanceOf(user) + staked, UserInitialRntToken);
        vm.warp(block.timestamp + 1 days);

        stakingContract.unlock();
        vm.warp(block.timestamp + 1 days);

        stakingContract.unstake(20*10**18);
        (staked, unclaimed, lastUpdateTime) = stakingContract.stakeInfos(user);
        assertEq(staked, 40*10**18);

        // After unlocking, esRNT tokens are minted as user tokens, visible in the account
        assertGe(unclaimed, 0);

        // User initially staked 60 RntTokens, unlocked after one day, then unstaked 20 RntTokens
        // RntToken account balance is 40, esRntToken account balance is 60
        // The total of staked RntTokens and remaining RntTokens is still 100, staking did not generate RntToken income for the user
        assertEq(rntToken.balanceOf(user), 60*10**18);
        assertEq(rntToken.balanceOf(user) + staked, UserInitialRntToken);
        assertGt(esRntToken.balanceOf(user), 0);

        vm.warp(block.timestamp + 31 days);

        // Specify a lock record (0 is the first), claim all that can be claimed, burn the rest
        stakingContract.claim(0);
        (staked, unclaimed, lastUpdateTime) = stakingContract.stakeInfos(user);
        assertEq(staked, 40*10**18);
        assertEq(unclaimed, 0);
        assertGe(rntToken.balanceOf(user), 60*10**18);
        assertEq(esRntToken.balanceOf(user), 0);
        assertGe(rntToken.balanceOf(user) + staked, UserInitialRntToken);

        stakingContract.unlock();
        vm.warp(block.timestamp + 31 days);
        stakingContract.claim(1);
        assertGt(rntToken.balanceOf(user), 60*10**18);
        assertEq(unclaimed, 0);
        vm.stopPrank();
    }

    function testPermitTransferFrom() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: user,
            spender: address(stakingContract),
            value: 1,
            nonce: 0,
            deadline: 1 days
        });
        bytes32 typehash = keccak256(
            "PermitStake(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );
        bytes32 digest = sigUtils.getDigest(permit, typehash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        rntToken.permit(
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );
        assertEq(rntToken.allowance(user, address(stakingContract)), 1);
        assertEq(rntToken.nonces(user), 1);
        vm.prank(address(stakingContract));
        rntToken.transferFrom(user, address(stakingContract), permit.value);
    }



    function testUnstakeMoreThanStaked() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: user,
            spender: address(stakingContract),
            value: 60 * 10**18,
            nonce: 0,
            deadline: 1 days
        });
        bytes32 typehash = keccak256(
            "PermitStake(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );
        bytes32 digest = sigUtils.getDigest(permit, typehash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        vm.startPrank(user);
        stakingContract.stake(60*10**18, permit.deadline, v, r, s);
        vm.warp(block.timestamp + 1 days);
        stakingContract.unlock();
        vm.warp(block.timestamp + 1 days);
        vm.expectRevert("Insufficient staked amount");
        stakingContract.unstake(80*10**18);
        vm.stopPrank();
    }
}