//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// URI is a formal system for uniquely identifing recouses it consists of 2 types which are URL and URN
// get all the behaviour we need from the ERC721URIStorage
contract RealEstate is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    // In the constructer I will be required to enter name of the NFT
    constructor() ERC721("Real Item", "REAL") {}
    // mint function will allow user to mint new NFT with specific URI
        function mint(string memory tokenURI) public returns(uint256) {
            // update the token ID
            _tokenIds.increment();

            // turn into new Item id
            uint256 newItemId = _tokenIds.current();

            // mint it with internal minting function from library
            _mint(msg.sender, newItemId);

            // will set the token URI 
            _setTokenURI(newItemId, tokenURI);

            return newItemId;
    }

    //show the total supply of the number of NFTs minted
    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }

}
