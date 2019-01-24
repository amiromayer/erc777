pragma solidity ^0.5.2;

import "../erc777/contracts/IERC777TokensRecipient.sol";
import "../erc820/contracts/ERC820Client.sol";
import "../erc820/contracts/IERC820Implementer.sol";
import "../utils/Ownable.sol";

contract TokensRecipient is ERC820Client, ERC820Implementer, ERC777TokensRecipient, Ownable {

    bytes32 constant ERC820_ACCEPT_MAGIC = keccak256(abi.encodePacked("ERC820_ACCEPT_MAGIC"));
    bool private allowTokensReceived;
    bool public notified;
    
    constructor(bool _setInterface) public {

        if (_setInterface) 
            setInterfaceImplementation("ERC777TokensRecipient", address(this)); 

        allowTokensReceived = true;
    }

    function tokensReceived(address _operator, address _from, address _to, uint256 _amount, bytes memory _data, bytes memory _operatorData) public {
        require(allowTokensReceived, "Receive not allowed.");
        notified = true;
    }

    function acceptTokens() public onlyOwner() {
        allowTokensReceived = true; 
    }

    function rejectTokens() public onlyOwner() { 
        allowTokensReceived = false; 
    }

    function canImplementInterfaceForAddress(address addr, bytes32 interfaceHash) public view returns(bytes32) {
        return ERC820_ACCEPT_MAGIC;
    }
}