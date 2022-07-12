// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./base64.sol";

contract DATASETNFT is ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    event tokenChanged(uint256 tokenId);

    Counters.Counter private _tokenIdCounter;
    string private _contractURI;

    mapping(uint256 => string) private _svgSources;

    constructor() ERC721("Dataset", "Dataset") {}

    function formatTokenURI(string memory _id, string memory _primary, string memory _evolutionary, string memory _tertiary, string memory _mask) public pure returns (string memory) {
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"id":"', _id,
                            '", "primary": "', _primary, '"',
                            ', "evolutionary": ', _evolutionary,
                            ', "tertiary": ', _tertiary,
                            ', "mask":"', _mask, '"}'
                        )
                    )
                )
            )
        );
    }

    function safeMint(string memory _id, string memory _primary, string memory _evolutionary, string memory _tertiary, string memory _mask) public onlyOwner() {
        _tokenIdCounter.increment();
        _safeMint(msg.sender, _tokenIdCounter.current());
        _setTokenURI(_tokenIdCounter.current(), formatTokenURI(_id, _primary, _evolutionary, _tertiary, _mask));
        emit tokenChanged(_tokenIdCounter.current());
    }

 // Delete data altering possibility
 // function setTokenURI(uint256 _tokenId, string memory _tokenURI) public onlyOwner() {
 //     _setTokenURI(_tokenId, _tokenURI);
 //     emit tokenChanged(_tokenId);
 // }

    function setContractURI(string memory contractURI_) public onlyOwner() {
        _contractURI = string(abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        contractURI_
                    )
                )
            ));
    }

    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

    function withdraw(address payable _to) public onlyOwner() {
        uint256 balance = address(this).balance;
        _to.transfer(balance);
    }

    /// The following functions are overrides required by Solidity for ERC721Enumerable.
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /// The following functions are overrides required by Solidity for ERC721URIStorage.
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
