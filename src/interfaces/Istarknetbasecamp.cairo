%lang starknet

from starkware.cairo.common.uint256 import Uint256


@contract_interface
namespace IStarknetBaseCamp:
    func getOwner() -> (owner: felt):
    end

    func name() -> (name: felt):
    end

    func symbol() -> (symbol: felt):
    end

    func totalSupply() -> (total_supply: Uint256):
    end

    func balanceOf(owner: felt) -> (balance: Uint256):
    end

    func ownerOf(token_id: Uint256) -> (owner: felt):
    end

    func safeTransferFrom(
            _from: felt, 
            to: felt, 
            token_id: Uint256, 
            data_len: felt,
            data: felt*
        ):
    end

    func transferFrom(_from: felt, to: felt, token_id: Uint256):
    end

    func paused() -> (is_paused: felt):
    end

    func approve(approved: felt, token_id: Uint256):
    end

    func setApprovalForAll(operator: felt, approved: felt):
    end

    func getApproved(token_id: Uint256) -> (approved: felt):
    end

    func isApprovedForAll(owner: felt, operator: felt) -> (is_approved: felt):
    end

    func tokenURI(token_id: Uint256) -> (token_uri_len: felt, token_uri: felt*):
    end

    func setTokenURI(token_uri_len: felt, token_uri: felt*):
    end

    func baseCampCohortAddress() -> (address: felt):
    end

    func setBaseCampCohortAddress(address: felt) -> ():
    end

    func mint(to: felt, token_id: Uint256):
    end

    func burn(token_id: Uint256):
    end

    func transferOwnership(new_owner: felt) -> (new_owner: felt):
    end

    func upgrade(new_implementation: felt) -> ():
    end
end