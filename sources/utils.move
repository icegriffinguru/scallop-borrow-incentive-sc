#[allow(unused_const, unused_type_parameter, unused_field, unused_use, unused_variable)]
module borrow_incentive::utils {
    const U64_MAX: u128 = 18446744073709551615u128;
    
    const DIVIDE_BY_ZERO_ERR: u64 = 0;
    const OVER_FLOW_ERR: u64 = 1;


    public fun mul_div(a: u64, b: u64, c: u64): u64 {
        abort 0
    }

    public fun u128_mul_div(a: u128, b: u128, c: u128): u128 {
        abort 0
    }    
}