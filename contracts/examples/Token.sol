pragma solidity ^0.5.2;

import { ERC777ERC20BaseToken } from "../erc777/contracts/ERC777ERC20BaseToken.sol";
import { Ownable } from "../utils/Ownable.sol";


contract Token is ERC777ERC20BaseToken, Ownable {

    event ERC20Enabled();
    event ERC20Disabled();

    address private mBurnOperator;

    constructor(string memory _name, string memory _symbol, uint256 _granularity, address[] memory _defaultOperators, address _burnOperator, uint256 _initialSupply) public ERC777ERC20BaseToken(_name, _symbol, _granularity, _defaultOperators) {
        mBurnOperator = _burnOperator;
        doMint(msg.sender, _initialSupply, "");
    }

    /// @notice Disables the ERC20 interface. This function can only be called
    ///  by the owner.
    function disableERC20() public onlyOwner {
        mErc20compatible = false;
        setInterfaceImplementation("ERC20Token", address(0));
        emit ERC20Disabled();
    }

    /// @notice Re enables the ERC20 interface. This function can only be called
    ///  by the owner.
    function enableERC20() public onlyOwner {
        mErc20compatible = true;
        setInterfaceImplementation("ERC20Token", address(this));
        emit ERC20Enabled();
    }

    /* -- Mint And Burn Functions (not part of the ERC777 standard, only the Events/tokensReceived call are) -- */
    //
    /// @notice Generates `_amount` tokens to be assigned to `_tokenHolder`
    ///  Sample mint function to showcase the use of the `Minted` event and the logic to notify the recipient.
    /// @param _tokenHolder The address that will be assigned the new tokens
    /// @param _amount The quantity of tokens generated
    /// @param _operatorData Data that will be passed to the recipient as a first transfer
    function mint(address _tokenHolder, uint256 _amount, bytes memory _operatorData) public onlyOwner {
        doMint(_tokenHolder, _amount, _operatorData);
    }

    /// @notice Burns `_amount` tokens from `msg.sender`
    ///  Silly example of overriding the `burn` function to only let the owner burn its tokens.
    ///  Do not forget to override the `burn` function in your token contract if you want to prevent users from
    ///  burning their tokens.
    /// @param _amount The quantity of tokens to burn
    function burn(uint256 _amount, bytes memory _data) public onlyOwner {
        super.burn(_amount, _data);
    }

    /// @notice Burns `_amount` tokens from `_tokenHolder` by `_operator`
    ///  Silly example of overriding the `operatorBurn` function to only let a specific operator burn tokens.
    ///  Do not forget to override the `operatorBurn` function in your token contract if you want to prevent users from
    ///  burning their tokens.
    /// @param _tokenHolder The address that will lose the tokens
    /// @param _amount The quantity of tokens to burn
    function operatorBurn(address _tokenHolder, uint256 _amount, bytes memory _data, bytes memory _operatorData) public {
        require(msg.sender == mBurnOperator, "Not a burn operator.");
        super.operatorBurn(_tokenHolder, _amount, _data, _operatorData);
    }

    function doMint(address _tokenHolder, uint256 _amount, bytes memory _operatorData) private {
        requireMultiple(_amount);
        mTotalSupply = mTotalSupply.add(_amount);
        mBalances[_tokenHolder] = mBalances[_tokenHolder].add(_amount);

        callRecipient(msg.sender, address(0), _tokenHolder, _amount, "", _operatorData, true);

        emit Minted(msg.sender, _tokenHolder, _amount, _operatorData);

        if (mErc20compatible) 
            emit Transfer(address(0), _tokenHolder, _amount); 
    }
}