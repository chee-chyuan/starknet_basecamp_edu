# SPDX-License-Identifier: MIT

%lang starknet
%builtins pedersen range_check ecdsa

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256

from src.tokens.basecamp.library import StarknetBaseCamp


#
# Constructor
#

@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(name: felt, symbol: felt, owner: felt, proxy_admin: felt, basecamp_cohort_address: felt, token_uri_len: felt, token_uri: felt*):
    return StarknetBaseCamp.constructor(
        name,
        symbol,
        owner,
        proxy_admin,
        basecamp_cohort_address,
        token_uri_len,
        token_uri,
    )
end

#
# Getters
#

@view
func getOwner{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (owner: felt):
    return StarknetBaseCamp.getOwner()
end

@view
func supportsInterface{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(interface_id: felt) -> (success: felt):
    return StarknetBaseCamp.supportsInterface(interface_id)
end

@view
func name{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (name: felt):
    return StarknetBaseCamp.name()
end

@view
func symbol{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (symbol: felt):
    return StarknetBaseCamp.symbol()
end

@view
func totalSupply{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (total_supply: Uint256):
    return StarknetBaseCamp.totalSupply()
end

@view
func balanceOf{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt) -> (balance: Uint256):
    return StarknetBaseCamp.balanceOf(owner)
end

@view
func ownerOf{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(token_id: Uint256) -> (owner: felt):
    return StarknetBaseCamp.ownerOf(token_id)
end

@view
func getApproved{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(token_id: Uint256) -> (approved: felt):
    return StarknetBaseCamp.getApproved(token_id)
end

@view
func isApprovedForAll{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt, operator: felt) -> (is_approved: felt):
    return StarknetBaseCamp.isApprovedForAll(owner, operator)
end

@view
func tokenURI{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(token_id: Uint256) -> (token_uri_len: felt, token_uri: felt*):
    return StarknetBaseCamp.tokenURI(token_id)
end

@view
func paused{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> (is_paused: felt):
    return StarknetBaseCamp.paused()
end

#
# Externals
#

@external
func approve{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(to: felt, token_id: Uint256):
    return StarknetBaseCamp.approve(to, token_id)
end

@external
func setApprovalForAll{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(operator: felt, approved: felt):
    return StarknetBaseCamp.setApprovalForAll(operator, approved)
end

@external
func transferFrom{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(_from: felt, to: felt, token_id: Uint256):
    return StarknetBaseCamp.transferFrom(_from, to, token_id)
end

@external
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
    return StarknetBaseCamp.safeTransferFrom(_from, to, token_id, data_len, data)
end

@external
func pause{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }():
    return StarknetBaseCamp.pause()
end

@external
func unpause{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }():
    return StarknetBaseCamp.unpause()
end

@external
func setTokenURI{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(token_uri_len: felt, token_uri: felt*):
    return StarknetBaseCamp.setTokenURI(token_uri_len, token_uri)
end

@external
func setBaseCampCohortAddress{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(address: felt):
    return StarknetBaseCamp.setBaseCampCohortAddress(address)
end

@external
func mint{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(to: felt, token_id: Uint256):
    return StarknetBaseCamp.mint(to, token_id)
end

@external
func burn{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(token_id: Uint256):
    return StarknetBaseCamp.burn(token_id)
end

@external
func safeMint{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(to: felt, token_id: Uint256, data_len: felt, data: felt*):
    return StarknetBaseCamp.safeMint(to, token_id, data_len, data)
end

@external
func transferOwnership{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(new_owner: felt) -> (new_owner: felt):
    return StarknetBaseCamp.transferOwnership(new_owner)
end

@external
func upgrade{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(new_implementation: felt) -> ():
    return StarknetBaseCamp.upgrade(new_implementation)
end
