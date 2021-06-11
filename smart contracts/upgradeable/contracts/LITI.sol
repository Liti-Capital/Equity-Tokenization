// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20CappedUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract LitiCapital is
    ERC20CappedUpgradeable,
    OwnableUpgradeable,
    PausableUpgradeable
{
    struct tokenRecoverInfo {
        uint256 lockExpires;
        address newAddress;
    }

    mapping(address => bool) private isApproved;
    mapping(address => bool) private isFrozen;
    mapping(address => tokenRecoverInfo) private tokenRecoverRecords;

    event Freeze(address account, bytes32 data);
    event Unfreeze(address account, bytes32 data);
    event UserApproved(address account, bytes32 data);
    event TokenRecoverRequested(
        address currentAddress,
        address newAddress,
        bytes32 data
    );

    function initialize() public initializer {
        __ERC20_init("LitiCapital", "LITI");
        __ERC20Capped_init(12000000);
        __Ownable_init();
        __Pausable_init();
        require(approveUser(hex"00", msg.sender));
    }

    /**
     * @dev return the value of decimals as 0.
     */
    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    /**
     * @dev return true if {account} is paused.
     */
    function freezeStatus(address account) public view returns (bool) {
        return isFrozen[account];
    }

    /**
     * @dev return true if {account} is approved.
     */
    function approvalStatus(address account) public view returns (bool) {
        return isApproved[account];
    }

    /**
     * @dev Set an {account} as approved.
     * {data} represent encrypted information about the user approved
     *
     * Emits {UserApproved} event
     */
    function approveUser(bytes32 data, address account)
        public
        onlyOwner
        returns (bool)
    {
        require(!isApproved[account], "The account has already been approved");
        isApproved[account] = true;
        emit UserApproved(account, data);
        return true;
    }

    /**
     * @dev Unfreeze {account}.
     * {data} represent encrypted information about the reasons for unfreezing.
     *
     * Emits {Unfreeze} event
     */
    function unfreeze(bytes32 data, address account)
        public
        onlyOwner
        returns (bool)
    {
        require(isFrozen[account], "The account is not frozen");
        isFrozen[account] = false;
        emit Unfreeze(account, data);
        return true;
    }

    /**
     * @dev Freeze {account}.
     * {data} represent encrypted information about the reasons for freezing.
     *
     * Emits {Freeze} event
     */
    function freeze(bytes32 data, address account)
        public
        onlyOwner
        returns (bool)
    {
        require(!isFrozen[account], "The account has been already frozen");
        isFrozen[account] = true;
        emit Freeze(account, data);
        return true;
    }

    /**
     * @dev Pause contract.
     */
    function PauseContract() public onlyOwner returns (bool) {
        require(!paused(), "Contract is already paused");
        _pause();
        return true;
    }

    /**
     * @dev Resume contract.
     */
    function UnpauseContract() public onlyOwner returns (bool) {
        require(paused(), "Contract is not paused");
        _unpause();
        return true;
    }

    /**
     * @dev Issues an {amount} new shares to {recipient}.
     */
    function issue(address recipient, uint256 amount)
        public
        onlyOwner
        returns (bool)
    {
        _mint(recipient, amount);
        return true;
    }

    /**
     * @dev Checks before transfering tokens {from} and {to} are not:
     * paused, unApproved. Also checks if the contract is not paused
     *
     * Requirements:
     *      {to} is approved
     *      {to} is not paused
     *      {from} is not paused
     *      Contract is not paused
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(isApproved[to], "Transfer to unapproved user");
        require(!isFrozen[to], "Transfer to paused user");
        require(!isFrozen[from], "Transfer from paused user");
        require(!paused(), "Contract paused");
    }

    /**
     * @dev In case of lost access to wallet it can be used to start a
     * procedure to reasign tokens from {currentAddress} a to {newAddress}.
     * after a period of 30 days has passed.
     *
     * Emits a {TokenRecoverRequested} Event
     *
     */
    function tokenRecoveryRequest(
        address currentAccount,
        address newAccount,
        bytes32 data
    ) public onlyOwner returns (bool) {
        uint256 lockExpires = block.timestamp + (30) * 1 days;
        tokenRecoverRecords[currentAccount] = tokenRecoverInfo(
            lockExpires,
            newAccount
        );
        isFrozen[currentAccount] = true;
        emit TokenRecoverRequested(currentAccount, newAccount, data);
        return true;
    }

    /**
     * @dev Allows token reassignment after lock period expires
     *
     * Emits a {Transfer} Event
     *
     * Requirements:
     *      Current timestamp is larger than the {lockExpires}
     *      records
     */
    function recoverTokens(address from) public onlyOwner returns (bool) {
        tokenRecoverInfo memory info = tokenRecoverRecords[from];
        require(
            info.lockExpires <= block.timestamp,
            "Attempted token recovery before lock period expiration"
        );
        _transfer(from, info.newAddress, balanceOf(from));
        tokenRecoverRecords[from] = tokenRecoverInfo(0, address(0));
        return true;
    }

    /**
     * @dev Allows burning tokens in the {owner()} account
     */
    function burn() public onlyOwner returns (bool) {
        _burn(owner(), balanceOf(owner()));
        return true;
    }
}
