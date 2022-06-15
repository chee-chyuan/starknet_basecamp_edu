%lang starknet
from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IBaseCampCohort0:

    func set_erc20_addresses(
        bridge_addr:felt, cairo_101_addr: felt
    ):
    end

    func set_moderator(
        address:felt, is_moderator:felt    
    ):
    end

    func set_required_point(
        erc20_token_address:felt, point: Uint256
    ):
    end

    func set_allow_register(
        can_register:felt    
    ):
    end

    func student_register():
    end

    func is_moderator(
        address:felt
    ) -> (res:felt):
    end

    func has_registered(
        address:felt
    ) -> (res:felt):
    end

    func is_allowed_to_register(
    ) -> (res: felt):
    end

    func get_required_points(
        erc20_contract_address: felt
    ) -> (res: Uint256):    
    end

    func is_complete_course(
        address:felt
    ) -> (res:felt):
    end

    func set_starknet_basecamp_address(address: felt):
    end

    func starknet_basecamp_address() -> (res:felt):
    end

    func mint_basecamp_token():
    end

    func claimed_token(address: felt) -> (bool:felt):
    end
end