// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IERC1363Receiver {
    function onTransferReceived(address from, uint256 value) external returns (bytes4);
}

contract BaseERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000 * (10 ** uint256(decimals));
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        if (isContract(_to)) {
            require(IERC1363Receiver(_to).onTransferReceived(msg.sender, _value) == IERC1363Receiver.onTransferReceived.selector, "ERC20: transfer to non ERC1363Receiver implementer");
        }

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");
        require(allowances[_from][msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");

        balances[_from] -= _value;
        balances[_to] += _value;
        allowances[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        if (isContract(_to)) {
            require(IERC1363Receiver(_to).onTransferReceived(_from, _value) == IERC1363Receiver.onTransferReceived.selector, "ERC20: transfer to non ERC1363Receiver implementer");
        }

        return true;
    }
    error ERC721InvalidApprover(address approver);
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract TokenBank is IERC1363Receiver {
    BaseERC20 public token;
    mapping(address => uint256) public balances;

    constructor(BaseERC20 _token) {
        token = _token;
    }

    function deposit(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than zero");

        try token.transferFrom(msg.sender, address(this), _amount) returns (bool success) {
            require(success, "Token transfer failed");
            balances[msg.sender] += _amount;
        } catch {
            revert("Token transfer failed");
        }
    }

    function withdraw(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than zero");
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;

        try token.transfer(msg.sender, _amount) returns (bool success) {
            require(success, "Token transfer failed");
        } catch {
            revert("Token transfer failed");
        }
    }

    function onTransferReceived(address from, uint256 value) external override returns (bytes4) {
        require(msg.sender == address(token), "Invalid token");
        balances[from] += value;
        return IERC1363Receiver.onTransferReceived.selector;
    }
}

contract NFT is ERC721URIStorage {
    uint256 public Tokenid;

    constructor() ERC721("greatgeoff", "GeoffNFT") {}

    function mint(address _minter, string memory _TokenURI) public returns (uint256) {
        _mint(_minter, ++Tokenid);
        _setTokenURI(Tokenid, _TokenURI);

        return Tokenid;
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        return tokenURI(tokenId);
    }
}

contract NFTMarket is IERC721Receiver {
    mapping(uint => uint) public nftPrices;
    mapping(uint => address) public nftSellers;
    BaseERC20 public immutable ERC20Token;
    IERC721 public immutable nftContract;

    event OnERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes data
    );

    constructor(address _TokenAddr, address _NFTContractAddr) {
        ERC20Token = BaseERC20(_TokenAddr);
        nftContract = IERC721(_NFTContractAddr);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function buyNFT(uint _nftId) external {
        require(nftSellers[_nftId] != address(0), "NFT not listed for sale");
        require(nftSellers[_nftId] != msg.sender, "Cannot buy your own NFT");
        require(ERC20Token.allowance(msg.sender, address(this)) >= nftPrices[_nftId], "ERC20: transfer amount exceeds allowance");
        require(ERC20Token.balanceOf(msg.sender) >= nftPrices[_nftId], "ERC20: transfer amount exceeds balance");

        ERC20Token.transferFrom(
            msg.sender,
            nftSellers[_nftId],
            nftPrices[_nftId]
        );
        nftContract.transferFrom(address(this), msg.sender, _nftId);

        // Clear the listing
        nftSellers[_nftId] = address(0);
        nftPrices[_nftId] = 0;
    }

    function listNFT(uint _nftId, uint price) public {
        require(nftContract.ownerOf(_nftId) == msg.sender, "ERC721: transfer caller is not owner nor approved");
        nftContract.safeTransferFrom(msg.sender, address(this), _nftId, "");
        nftPrices[_nftId] = price;
        nftSellers[_nftId] = msg.sender;
    }
}

    contract MockContract {
        NFTMarket public market;
        BaseERC20 public token;
        NFT public nft;

        constructor(NFTMarket _market, BaseERC20 _token, NFT _nft) {
            market = _market;
            token = _token;
            nft = _nft;
        }

        function interact(uint _nftId, uint _price) external {
            nft.approve(address(market), _nftId);
            market.listNFT(_nftId, _price);
        }
    }


