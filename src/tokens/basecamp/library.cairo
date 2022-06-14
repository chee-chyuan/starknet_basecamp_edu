# SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.math import assert_not_zero, assert_not_equal
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import (
    Uint256, uint256_add, uint256_sub
)

from openzeppelin.introspection.ERC165 import ERC165
from openzeppelin.access.ownable import Ownable
from openzeppelin.security.pausable import Pausable
from openzeppelin.upgrades.library import Proxy
from openzeppelin.token.erc721.interfaces.IERC721_Receiver import IERC721_Receiver

from src.tokens.basecamp.metadata import StarknetBaseCampMetadata

#
# Storage
#

@storage_var
func ERC721_name_() -> (name: felt):
end

@storage_var
func ERC721_symbol_() -> (symbol: felt):
end

@storage_var
func ERC721_total_supply_() -> (total_supply: Uint256):
end

@storage_var
func ERC721_owners(token_id: Uint256) -> (owner: felt):
end

@storage_var
func ERC721_balances(account: felt) -> (balance: Uint256):
end

@storage_var
func ERC721_token_approvals(token_id: Uint256) -> (res: felt):
end

@storage_var
func ERC721_operator_approvals(owner: felt, operator: felt) -> (res: felt):
end

@storage_var
func basecamp_cohort_address_() -> (address: felt):
end

#
# Events
#

@event
func Transfer(_from: felt, to: felt, tokenId: Uint256):
end

@event
func Approve(owner: felt, approved: felt, tokenId: Uint256):
end

@event
func ApprovalForAll(owner: felt, operator: felt, approved: felt):
end

namespace StarknetBaseCamp:
    #
    # Constructor
    #

    func constructor{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(
            name: felt,
            symbol: felt,
            owner: felt,
            proxy_admin:felt,
            basecamp_cohort_address: felt,
            token_uri_len: felt,
            token_uri: felt*,
        ):
        ERC721_name_.write(name)
        ERC721_symbol_.write(symbol)
        basecamp_cohort_address_.write(basecamp_cohort_address)
        Ownable.initializer(owner)
        Proxy.initializer(proxy_admin)
        StarknetBaseCampMetadata.ERC721_Metadata_initializer()
        StarknetBaseCampMetadata.ERC721_Metadata_setTokenURI(token_uri_len, token_uri)
        # register IERC721
        ERC165.register_interface(0x80ac58cd)
        return ()
    end

    #
    # Getters
    #

    func getOwner{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }() -> (owner: felt):
        return Ownable.owner()
    end

    func supportsInterface{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(interface_id: felt) -> (success: felt):
        return ERC165.supports_interface(interface_id)
    end

    func name{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }() -> (name: felt):
        let (name) = ERC721_name_.read()
        return (name)
    end

    func symbol{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }() -> (symbol: felt):
        let (symbol) = ERC721_symbol_.read()
        return (symbol)
    end

    func totalSupply{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }() -> (total_supply: Uint256):
        let (total_supply) = ERC721_total_supply_.read()
        return (total_supply)
    end

    func balanceOf{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(owner: felt) -> (balance: Uint256):
        let (balance: Uint256) = ERC721_balances.read(owner)
        assert_not_zero(owner)
        return (balance)
    end

    func ownerOf{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }(token_id: Uint256) -> (owner: felt):
        let (owner) = ERC721_owners.read(token_id)
        # Ensuring the query is not for nonexistent token
        assert_not_zero(owner)
        return (owner)
    end

    func tokenURI{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }(token_id: Uint256) -> (token_uri_len: felt, token_uri: felt*):
        return StarknetBaseCampMetadata.ERC721_Metadata_tokenURI(token_id)
    end

    func getApproved{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }(token_id: Uint256) -> (approved: felt):
        let (exists) = internal.exists(token_id)
        assert exists = 1

        let (approved) = ERC721_token_approvals.read(token_id)
        return (approved)
    end

    func isApprovedForAll{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }(owner: felt, operator: felt) -> (is_approved: felt):
        let (is_approved) = ERC721_operator_approvals.read(owner=owner, operator=operator)
        return (is_approved)
    end

    func paused{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }() -> (is_paused: felt):
        return Pausable.is_paused()
    end

    func baseCampCohortAddress{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }() -> (address: felt):
        let (address) = basecamp_cohort_address_.read()
        return (address)
    end

    #
    # Externals
    #

    func approve{
            pedersen_ptr: HashBuiltin*,
            syscall_ptr: felt*,
            range_check_ptr
        }(to: felt, token_id: Uint256):
        Pausable.assert_not_paused()
        # Checks caller is not zero address
        let (caller) = get_caller_address()
        assert_not_zero(caller)

        # Ensures 'owner' does not equal 'to'
        let (owner) = ERC721_owners.read(token_id)
        assert_not_equal(owner, to)

        # Checks that either caller equals owner or
        # caller isApprovedForAll on behalf of owner
        if caller == owner:
            internal.approve(owner, to, token_id)
            return ()
        else:
            let (is_approved) = ERC721_operator_approvals.read(owner, caller)
            assert_not_zero(is_approved)
            internal.approve(owner, to, token_id)
            return ()
        end
    end

    func setApprovalForAll{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }(operator: felt, approved: felt):
        Pausable.assert_not_paused()
        # Ensures caller is neither zero address nor operator
        let (caller) = get_caller_address()
        assert_not_zero(caller)
        assert_not_equal(caller, operator)

        # Make sure `approved` is a boolean (0 or 1)
        assert approved * (1 - approved) = 0

        ERC721_operator_approvals.write(owner=caller, operator=operator, value=approved)

        # Emit ApprovalForAll event
        ApprovalForAll.emit(owner=caller, operator=operator, approved=approved)
        return ()
    end

    func transferFrom{
            pedersen_ptr: HashBuiltin*,
            syscall_ptr: felt*,
            range_check_ptr
        }(_from: felt, to: felt, token_id: Uint256):
        alloc_locals

        Pausable.assert_not_paused()
        let (caller) = get_caller_address()
        let (is_approved) = internal.is_approved_or_owner(caller, token_id)
        assert_not_zero(caller * is_approved)
        # Note that if either `is_approved` or `caller` equals `0`,
        # then this method should fail.
        # The `caller` address and `is_approved` boolean are both field elements
        # meaning that a*0==0 for all a in the field,
        # therefore a*b==0 implies that at least one of a,b is zero in the field

        internal.transfer(_from, to, token_id)
        return ()
    end

    func safeTransferFrom{
            pedersen_ptr: HashBuiltin*,
            syscall_ptr: felt*,
            range_check_ptr
        }(
            _from: felt,
            to: felt,
            token_id: Uint256,
            data_len: felt,
            data: felt*
        ):
        alloc_locals

        Pausable.assert_not_paused()
        let (caller) = get_caller_address()
        let (is_approved) = internal.is_approved_or_owner(caller, token_id)
        assert_not_zero(caller * is_approved)
        # Note that if either `is_approved` or `caller` equals `0`,
        # then this method should fail.
        # The `caller` address and `is_approved` boolean are both field elements
        # meaning that a*0==0 for all a in the field,

        internal.safe_transfer(_from, to, token_id, data_len, data)
        return ()
    end

    func pause{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }():
        Ownable.assert_only_owner()
        Pausable._pause()
        return ()
    end

    func unpause{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }():
        Ownable.assert_only_owner()
        Pausable._unpause()
        return ()
    end

    func setTokenURI{
            pedersen_ptr: HashBuiltin*,
            syscall_ptr: felt*,
            range_check_ptr
        }(token_uri_len: felt, token_uri: felt*):
        Ownable.assert_only_owner()
        Pausable.assert_paused()
        StarknetBaseCampMetadata.ERC721_Metadata_setTokenURI(token_uri_len, token_uri)
        return ()
    end

    func setBaseCampCohortAddress{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }(address: felt):
        Ownable.assert_only_owner()
        assert_not_zero(address)
        basecamp_cohort_address_.write(address)
        return ()
    end

    func mint{
            pedersen_ptr: HashBuiltin*,
            syscall_ptr: felt*,
            range_check_ptr
        }(to: felt, token_id: Uint256):
        assert_not_zero(to)

        let (caller_address) = get_caller_address()
        with_attr error_message("StarknetBaseCamp: Caller cannot be zero address"):
            assert_not_zero(caller_address)
        end

        internal.assert_only_cohort_contract(caller_address)
        Pausable.assert_not_paused()

        # Ensures token_id is unique
        let (exists) = internal.exists(token_id)
        assert exists = 0

        let (balance: Uint256) = ERC721_balances.read(to)
        # Overflow is not possible because token_ids are checked for duplicate ids with `internal.exists)`
        # thus, each token is guaranteed to be a unique uint256
        let (new_balance: Uint256, _) = uint256_add(balance, Uint256(1, 0))
        ERC721_balances.write(to, new_balance)

        # low + high felts = uint256
        ERC721_owners.write(token_id, to)

        # Emit Transfer event
        Transfer.emit(_from=0, to=to, tokenId=token_id)
        return ()
    end

    func burn{
            pedersen_ptr: HashBuiltin*,
            syscall_ptr: felt*,
            range_check_ptr
        }(token_id: Uint256):
        alloc_locals
        Ownable.assert_only_owner()
        Pausable.assert_not_paused()
        let (local owner) = ownerOf(token_id)

        # Clear approvals
        internal.approve(owner, 0, token_id)

        # Decrease owner balance
        let (balance: Uint256) = ERC721_balances.read(owner)
        let (new_balance) = uint256_sub(balance, Uint256(1, 0))
        ERC721_balances.write(owner, new_balance)

        # Delete owner
        ERC721_owners.write(token_id, 0)

        # Emit Transfer event
        Transfer.emit(_from=owner, to=0, tokenId=token_id)
        return ()
    end

    func safeMint{
            pedersen_ptr: HashBuiltin*,
            syscall_ptr: felt*,
            range_check_ptr
        }(
            to: felt,
            token_id: Uint256,
            data_len: felt,
            data: felt*
        ):
        mint(to, token_id)
        internal.check_onERC721Received(
            0,
            to,
            token_id,
            data_len,
            data
        )
        return ()
    end

    func transferOwnership{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(new_owner: felt) -> (new_owner: felt):
        # Ownership check is handled by this function
        Ownable.transfer_ownership(new_owner)
        return (new_owner=new_owner)
    end

    func upgrade{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }(new_implementation: felt) -> ():
        Proxy.assert_only_admin()
        Proxy._set_implementation(new_implementation)
        return ()
    end
end

namespace internal:
    #
    # Internals
    #

    func assert_only_cohort_contract{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }(contract_address : felt):
        let (basecamp_cohort_contract_address) = basecamp_cohort_address_.read()
        with_attr error_message("StarknetBaseCamp: Only the BaseCamp Cohort contract can call this function"):
            assert basecamp_cohort_contract_address = contract_address
        end
        return ()
    end

    func approve{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }(owner: felt, to: felt, token_id: Uint256):
        ERC721_token_approvals.write(token_id, to)
        Approve.emit(owner=owner, approved=to, tokenId=token_id)
        return ()
    end

    func is_approved_or_owner{
            pedersen_ptr: HashBuiltin*,
            syscall_ptr: felt*,
            range_check_ptr
        }(spender: felt, token_id: Uint256) -> (res: felt):
        alloc_locals

        let (exists) = internal.exists(token_id)
        assert exists = 1

        let (owner) = StarknetBaseCamp.ownerOf(token_id)
        if owner == spender:
            return (1)
        end

        let (approved_addr) = StarknetBaseCamp.getApproved(token_id)
        if approved_addr == spender:
            return (1)
        end

        let (is_operator) = StarknetBaseCamp.isApprovedForAll(owner, spender)
        if is_operator == 1:
            return (1)
        end

        return (0)
    end

    func exists{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }(token_id: Uint256) -> (res: felt):
        let (res) = ERC721_owners.read(token_id)

        if res == 0:
            return (0)
        else:
            return (1)
        end
    end

    func transfer{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }(_from: felt, to: felt, token_id: Uint256):
        # ownerOf ensures '_from' is not the zero address
        let (_ownerOf) = StarknetBaseCamp.ownerOf(token_id)
        assert _ownerOf = _from

        assert_not_zero(to)

        # Clear approvals
        internal.approve(_ownerOf, 0, token_id)

        # Decrease owner balance
        let (owner_bal) = ERC721_balances.read(_from)
        let (new_balance) = uint256_sub(owner_bal, Uint256(1, 0))
        ERC721_balances.write(_from, new_balance)

        # Increase receiver balance
        let (receiver_bal) = ERC721_balances.read(to)
        # overflow not possible because token_id must be unique
        let (new_balance: Uint256, _) = uint256_add(receiver_bal, Uint256(1, 0))
        ERC721_balances.write(to, new_balance)

        # Update token_id owner
        ERC721_owners.write(token_id, to)

        # Emit transfer event
        Transfer.emit(_from=_from, to=to, tokenId=token_id)
        return ()
    end

    func safe_transfer{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }(
            _from: felt,
            to: felt,
            token_id: Uint256,
            data_len: felt,
            data: felt*
        ):
        internal.transfer(_from, to, token_id)

        let (success) = internal.check_onERC721Received(_from, to, token_id, data_len, data)
        assert_not_zero(success)
        return ()
    end

    func check_onERC721Received{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }(
            _from: felt,
            to: felt,
            token_id: Uint256,
            data_len: felt,
            data: felt*
        ) -> (success: felt):
        # We need to consider how to differentiate between EOA and contracts
        # and insert a conditional to know when to use the proceeding check
        let (caller) = get_caller_address()
        # The first parameter in an imported interface is the contract
        # address of the interface being called
        let (selector) = IERC721_Receiver.onERC721Received(
            to,
            caller,
            _from,
            token_id,
            data_len,
            data
        )

        # ERC721_RECEIVER_ID
        assert (selector) = 0x150b7a02

        # Cairo equivalent to 'return (true)'
        return (1)
    end
end