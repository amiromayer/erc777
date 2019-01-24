pragma solidity ^0.5.2;

import "../erc777/contracts/IERC777TokensSender.sol";
import "../erc820/contracts/ERC820Client.sol";
import "../erc820/contracts/IERC820Implementer.sol";
import "../utils/Ownable.sol";


contract TokensSender is ERC820Client, ERC820Implementer, ERC777TokensSender, Ownable {
    
    bytes32 constant ERC820_ACCEPT_MAGIC = keccak256(abi.encodePacked("ERC820_ACCEPT_MAGIC"));
    bool private allowTokensToSend;
    bool public notified;

    constructor(bool _setInterface) public {

        if (_setInterface) 
            setInterfaceImplementation("ERC777TokensSender", address(this));

        allowTokensToSend = true;
        notified = false;
    }

    function tokensToSend(address _operator, address _from, address _to, uint _amount, bytes memory _data, bytes memory _operatorData) public {
        require(allowTokensToSend, "Send not allowed.");
        notified = true;
       
    }

    function acceptTokensToSend() public onlyOwner() { 
        allowTokensToSend = true; 
    }

    function rejectTokensToSend() public onlyOwner() { 
        allowTokensToSend = false; 
    }

    function canImplementInterfaceForAddress(address addr, bytes32 interfaceHash) public view returns(bytes32) {
        return ERC820_ACCEPT_MAGIC;
    }

}