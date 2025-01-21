#[allow(unused_const, unused_type_parameter, unused_field, unused_use, unused_variable)]
module borrow_incentive::incentive_config {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use sui::transfer;

    friend borrow_incentive::admin;

    const CURRENT_VERSION: u64 = 1;

    const IncentiveDisabledErr: u64 = 0x1;
    const VersionMismatchErr: u64 = 0x2;
    const CanOnlyIncreaseVersionErr: u64 = 0x3;

    struct IncentiveConfig has key {
        id: UID,
        version: u64,
        enabled: bool,
    }

    public fun version(config: &IncentiveConfig): u64 { config.version }
    public fun enabled(config: &IncentiveConfig): bool { config.enabled }

    public fun assert_enabled(incentive_config: &IncentiveConfig) {
        abort 0
    }

    public fun assert_version(incentive_config: &IncentiveConfig) {
        abort 0
    }

    public fun assert_version_and_status(incentive_config: &IncentiveConfig) {
        abort 0
    }
}
