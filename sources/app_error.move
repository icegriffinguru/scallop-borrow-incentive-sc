#[allow(unused_const, unused_type_parameter, unused_field, unused_use, unused_variable)]
module borrow_incentive::app_error {
  public fun deprecated(): u64 { 1 }

  public fun reward_fee_recipient_not_exist(): u64 { 0x000001 }
}
