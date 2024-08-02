// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {GeoNFT} from "./GeoNFT.sol";
// import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "forge-std/console.sol";
contract NFTMarket_share {
    uint256 public I_Accumulate;
    uint256 public TotalFee;
    uint256 public TotalStake;
    // address public nft;
    uint256 public nft_id;

    struct stakeInfo_v1 {
        uint256 stake;
        uint256 unclaim;
        uint256 ini_I_Accumulate;
    }
    struct stakeInfo_v2{
        uint256 stake;
        uint256 ini_I_Accumulate;
    }

    struct nft_info{
        uint256 price;
        address owner;
        bool is_listed;
    }
    mapping (address => stakeInfo_v1) public stakers_v1;
    mapping (address => stakeInfo_v2) public stakers_v2;
    mapping (uint256 => nft_info) public nft_list;
    event SomeoneMintNFT(address owner, uint256 price, uint256 time);
    event SomeoneListNFT(address owner, uint256 price, uint256 time, bool is_listed);
    event SomeoneBuyNFT(uint256 id, uint256 price, uint256 time, uint256 fee);
    event SomeoneStakeETH(address staker, uint256 amount, uint256 time, uint256 feeShare, uint256 totalI, uint256 totalstake);
    event SomeoneUnstakeETH(address staker, uint256 amount, uint256 unclaim, uint256 time, uint256 feeShare, uint256 totalI, uint256 totalstake);
    event updateAccumulateFeeShareTo(uint256 I_Accumulate, uint256 TotalFee, uint256 TotalStake);
    GeoNFT nft;
    constructor(GeoNFT _nft){
        I_Accumulate = 0;
        TotalFee = 0;
        TotalStake = 0;
        nft_id = 1;
        nft = _nft;
    }
    function getPrice(uint256 _tokenId) public view returns (uint256 price) {
        return nft_list[_tokenId].price;
    }

    function listNFT(uint256 _tokenId, uint256 _price) public {
        require(msg.sender == nft.ownerOf(_tokenId), "You are not the owner of this NFT");
        nft_list[_tokenId].price = _price;
        nft_list[_tokenId].is_listed = true;
        emit SomeoneListNFT(nft_list[_tokenId].owner, nft_list[_tokenId].price, block.timestamp, nft_list[_tokenId].is_listed);
    }

    // function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {
    //     if (_returnData.length < 68) return 'Transaction reverted silently';
    //         assembly {
    //             _returnData := add(_returnData, 0x04)
    //         }
    //         return abi.decode(_returnData, (string));
    // }
    function buyNFT(uint256 id) public payable{
        uint256 fee;
        address buyer = msg.sender;
        // check if NFT is listed
        // check the price of the NFT(and what kind of token it accepts)
        // require(nft_list[id].is_listed == true, "NFT is not listed");
        uint256 price = getPrice(id);
        // check if the buyer has enough balance of this token. 
        require(msg.value >= price, "Not enough balance");
          // For the sake of simplicity, we assume it is ETH
          // If not, the transaction will revert.
        // transfer ETH from buyer to seller
        fee = price * 3 / 1000;
        uint256 earn = price - fee;
        // transfer ETH to nft owner
        (bool s,) = payable(nft.ownerOf(id)).call{value:earn}("");
        require(s);
          // charge 0.3% price of the NFT as fee, and transfer to the market contract
        // transfer NFT from seller to buyer

        nft.transferFrom(nft.ownerOf(id), buyer, id);

        // nft.safeTransferFrom(nft_list[id].owner, buyer, id);
        // calculate share and distribute to the each staker
        console.log("TotalStake:", TotalStake);
        if (TotalStake != 0) {
            // This variable shouldn't exist unless anybody staked.
            TotalFee += fee;
            I_Accumulate += TotalFee *10**18/ TotalStake;
            // I_Accumulate /= 10**18;
            console.log("I_Accumulate:", I_Accumulate);
        }

        emit SomeoneBuyNFT(id, price, block.timestamp, fee);
        emit updateAccumulateFeeShareTo(I_Accumulate, TotalFee, TotalStake);
    }
    
    function stakeETH_v1 () public payable {
        // This version do not add unclaim amount to stake amount automatically, user has to cliam
        uint256 amount = msg.value;
        // if unstake, TotalStake -= amount, stakers_v1[msg.sender].stake -= amount;
        uint256 unclaim = stakers_v1[msg.sender].unclaim;
        uint256 stake = stakers_v1[msg.sender].stake;
        uint256 ini_I_Accumulate = stakers_v1[msg.sender].ini_I_Accumulate;
        require(msg.value <= msg.sender.balance, "Not enough stake balance");
        
        // 第一步，质押前冻结收益
        unclaim += stake*(I_Accumulate - ini_I_Accumulate);
        
        // 第二步，更新市场状态，并把这个作为用户本次质押的市场初态 I0，unstake/claim的话把这部分改成减号就可以
        TotalStake += amount;
        stake += amount;

        // refresh stake
        I_Accumulate += TotalFee *10**18/ TotalStake;  
        
        // refresh state session of the staker
        stakers_v1[msg.sender].unclaim = unclaim;
        stakers_v1[msg.sender].stake = stake;
        stakers_v1[msg.sender].ini_I_Accumulate = I_Accumulate;
        emit SomeoneStakeETH(msg.sender, amount, block.timestamp, unclaim, I_Accumulate, TotalStake);
        // pay attention to the order
    }
    
    function stakeETH_v2(uint256 amount) public payable {
        
        // uint256 const TFee = TotalFee;

        // uint256 unclaim = stakers_v2[msg.sender].unclaim;
        uint256 stake = stakers_v2[msg.sender].stake;
        uint256 ini_I_Accumulate = stakers_v2[msg.sender].ini_I_Accumulate;
        
        // 第一步，质押前计算收益
        uint256 unclaim = stake*(I_Accumulate - ini_I_Accumulate);
        
        // 第二步，更新市场状态，并把这个作为用户本次质押的市场初态 I0，unstake/claim的话把这部分改成减号就可以
        // 将用户收益转换为质押持仓。因为当即就结算，自动复利了，所以不需要unclaim字段
        TotalStake += amount + unclaim;
        stake += amount + unclaim;

        // refresh stake
        I_Accumulate += TotalFee *10**18 / TotalStake;  
    
        // refresh state session of the staker
        stakers_v2[msg.sender].stake = stake;
        stakers_v2[msg.sender].ini_I_Accumulate = I_Accumulate;
    }

    function unstakeETH_v1 (uint256 amount) public payable {
        // This version do not add unclaim amount to stake amount automatically, user has to cliam

        // if unstake, TotalStake -= amount, stakers_v1[msg.sender].stake -= amount;
        uint256 unclaim = stakers_v1[msg.sender].unclaim;
        uint256 stake = stakers_v1[msg.sender].stake;
        uint256 ini_I_Accumulate = stakers_v1[msg.sender].ini_I_Accumulate;
        // console.log("unclaim:", unclaim);
        // console.log("stake:",stake);
        require(amount<= stake, "Not enough stake balance");
        // 第一步，质押前冻结收益
        unclaim += stake*(I_Accumulate - ini_I_Accumulate)/(10**18);
        console.log("stake*(I_Accumulate - ini_I_Accumulate)", stake*(I_Accumulate - ini_I_Accumulate));
        
        payable(msg.sender).transfer(amount);
        // 第二步，更新市场状态，并把这个作为用户本次质押的市场初态 I0，unstake/claim的话把这部分改成减号就可以
        TotalStake -= amount;
        stake -= amount;

        // refresh stake
        I_Accumulate += TotalFee *10**18/ TotalStake;  
    
        // refresh state session of the staker
        stakers_v1[msg.sender].unclaim = unclaim;
        stakers_v1[msg.sender].stake = stake;
        stakers_v1[msg.sender].ini_I_Accumulate = I_Accumulate;
        emit SomeoneUnstakeETH(msg.sender, amount, unclaim, block.timestamp, unclaim, I_Accumulate, TotalStake);
        // pay attention to the order
    }

    function claim() public {
        uint256 unclaim = stakers_v1[msg.sender].unclaim;
        stakers_v1[msg.sender].unclaim = 0;
        payable(msg.sender).transfer(unclaim);
        // unstakeETH_v1(unclaim);

    }
}
