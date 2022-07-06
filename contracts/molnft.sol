// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./base64.sol";

contract MOLNFT is ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    event tokenChanged(uint256 tokenId);

    Counters.Counter private _tokenIdCounter;
    string private _contractURI;

    mapping(uint256 => string) private _svgSources;

    constructor() ERC721("Molecule", "MolNFT") {}

    function svgToImageURI(string memory _source) public pure returns (string memory) {
        string memory baseURL = "data:application/octet-stream;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(_source))));
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }

    function formatTokenURI(string memory _imageURI, string memory _pdbid, string memory _title, string memory _sequences, string memory _organism, string memory _method, string memory _resolution) public pure returns (string memory) {
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"pdbid":"', _pdbid,
                            '", "title": "', _title, '"',
                            ', "sequences": ', _sequences,
                            ', "organism": ', _organism,
                            ', "method": ', _method,
                            ', "resolution": ', _resolution,
                            ', "image":"', _imageURI, '"}'
                        )
                    )
                )
            )
        );
    }

    function safeMint(string memory _source, string memory _pdbid, string memory _title, string memory _sequences, string memory _organism, string memory _method, string memory _resolution) public onlyOwner() {
        _tokenIdCounter.increment();
        _safeMint(msg.sender, _tokenIdCounter.current());
        string memory imageURI = svgToImageURI(_source);
        _setTokenURI(_tokenIdCounter.current(), formatTokenURI(imageURI, _pdbid, _title, _sequences, _organism, _method, _resolution));
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
