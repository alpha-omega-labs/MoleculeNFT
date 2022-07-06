// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import "./Base64.sol";

/// @author mbvissers on Medium
// USE AT YOUR OWN RISK
contract NFTONCHAIN is ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    event tokenChanged(uint256 tokenId);

    Counters.Counter private _tokenIdCounter;
    string private _contractURI;

    mapping(uint256 => string) private _svgSources;

    constructor() ERC721("Test", "T") {}

    function svgToImageURI(string memory _source) public pure returns (string memory) {
        // example:
        // <svg width='500' height='500' viewBox='0 0 285 350' fill='none' xmlns='http://www.w3.org/2000/svg'><path fill='black' d='M150,0,L75,200,L225,200,Z'></path></svg>
        // data:image/svg+xml;base64,PHN2ZyB3aWR0aD0nNTAwJyBoZWlnaHQ9JzUwMCcgdmlld0JveD0nMCAwIDI4NSAzNTAnIGZpbGw9J25vbmUnIHhtbG5zPSdodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2Zyc+PHBhdGggZmlsbD0nYmxhY2snIGQ9J00xNTAsMCxMNzUsMjAwLEwyMjUsMjAwLFonPjwvcGF0aD48L3N2Zz4=
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(_source))));
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }

    function formatTokenURI(string memory _imageURI, string memory _pdbid, string memory _title, string memory _sequences) public pure returns (string memory) {
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"pdbid":"', _pdbid,
                            '", "title": "', _title, '"',
                            ', "sequences": ', _sequences,
                            ', "image":"', _imageURI, '"}'
                        )
                    )
                )
            )
        );
    }

    function safeMint(string memory _source, string memory _pdbid, string memory _title, string memory _sequences) public onlyOwner() {
        _safeMint(msg.sender, _tokenIdCounter.current());
        string memory imageURI = svgToImageURI(_source);
        _setTokenURI(_tokenIdCounter.current(), formatTokenURI(imageURI, _pdbid, _title, _sequences));
        emit tokenChanged(_tokenIdCounter.current());
        _tokenIdCounter.increment();
    }

    function setTokenURI(uint256 _tokenId, string memory _tokenURI) public onlyOwner() {
        _setTokenURI(_tokenId, _tokenURI);
        emit tokenChanged(_tokenId);
    }

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
