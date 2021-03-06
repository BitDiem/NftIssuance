pragma solidity ^0.4.24;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "../contracts/issue/Issuance.sol";
import "../contracts/token/SharesToken.sol";
import "./mocks/MockNft.sol";

contract TestIssuance {

    function testIssuance() public {

        address issuer = address(this);

        MockNft nft = new MockNft();
        uint tokenId = 1;
        nft.mint(tokenId);

        uint numberOfShares = 10;

        Assert.equal(nft.ownerOf(tokenId), issuer, "Owner of token should be the issuer");

        // create a token representing shares, with 10 supply and entire supply held by this contract
        IERC20 token = new SharesToken("testName", "testSymbol", issuer, numberOfShares);

        Issuance issuance = new Issuance();

        // approve the issuance contract for transferring the NFT token
        nft.approve(issuance, tokenId);
        //nft.setApprovalForAll(issuance, true);

        // approve this contract for being able to call the Issuance contract on behalf of the token owner
        // ERROR - approval should not be needed since the caller (this) is the same as the spender
        //issuance.setApprovalForNft(issuer, nft, tokenId, true);
        //issuance.setApprovalForAll(issuer, nft);

        issuance.issue(issuer, nft, tokenId, token, 10);
        (,,, address bank) = issuance.find(nft, tokenId);
        address tokenHolder = bank; // address(issuance);

        Assert.equal(nft.ownerOf(tokenId), tokenHolder, "Owner of token should now be the Issuance contract");

        // approve the issuance contract for transferring the shares tokens
        token.approve(issuance, 99999);

        issuance.redeem(issuer, token, numberOfShares);

        Assert.equal(nft.ownerOf(tokenId), address(issuer), "Owner of token should now be the issuer");
    }
}