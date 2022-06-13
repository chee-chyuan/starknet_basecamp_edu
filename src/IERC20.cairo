%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IERC20:
    func balanceOf(account: felt) -> (balance: Uint256):
    end
end