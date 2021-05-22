// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract wLitiCapital is ERC20 {
    address litiAddress;

    event Wrapped(address user, uint256 amount);
    event Unwrapped(address user, uint256 amount);

    constructor(address _litiAddress) ERC20("wLitiCapital", "wLITI") {
        litiAddress = _litiAddress;
    }

    /*
     * Receives {amount} of shares (LITI) and mint {amount} fo wLITI Token
     * the conversion is one to one but the wrapped token has 18 decimal points.
     *
     * Emits {Wrapped} event
     *
     * Requirements:
     *       user account should ahev approved this contract to transfer
     *       the {amount} of shres from LITI token contract
     */
    function wrap(uint256 amount) public {
        IERC20 liti = IERC20(litiAddress);
        require(liti.transferFrom(msg.sender, address(this), amount));
        _mint(msg.sender, amount * (10**18));
        emit Wrapped(msg.sender, amount);
    }

    /*
     * Burns {amount} of wLITI and transfer {amount} fo LITI to user
     *
     * Emits {unwrapped} event
     *
     * Requirements:
     *       user account should ahev approved this contract to transfer
     *       the {amount} of shres from LITI token contract
     */
    function unwrap(uint256 amount) public {
        _burn(msg.sender, amount * (10**18));
        IERC20 liti = IERC20(litiAddress);
        require(liti.transfer(msg.sender, amount));
        emit Unwrapped(msg.sender, amount);
    }
}
