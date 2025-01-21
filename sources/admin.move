#[allow(unused_const, unused_type_parameter, unused_field, unused_use, unused_variable, unused_mut_parameter)]
module borrow_incentive::admin {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::clock::{Self, Clock};
    use sui::event::emit;
    use std::option::{Self, Option};
    use std::type_name::{Self, TypeName};

    use borrow_incentive::incentive_pool::{Self, IncentivePools};
    use borrow_incentive::incentive_account;
    use borrow_incentive::typed_id;
    use borrow_incentive::app_error;
    use borrow_incentive::incentive_config::{Self, IncentiveConfig};

    struct AdminCap has key, store {
        id: UID,
    }

    struct CreateIncentivePoolsEvent has copy, drop {
        incentive_pools_id: ID,
        incentive_accounts_id: ID,
    }

    struct UpdateIncentivePoolPointEvent has copy, drop {
        incentive_pool_id: ID,
        pool_type: TypeName,
        point_type: TypeName,
        incentive_duration: u64,
        distributed_point_per_period: u64,
        previous_points: u64,
        current_points: u64,
        updated_at: u64,
    }

    struct UpdateIncentivePoolParamsEvent has copy, drop {
        incentive_pool_id: ID,
        pool_type: TypeName,
        max_stakes: u64,
    }

    struct UpdateRewardFeeConfigEvent has copy, drop {
        incentive_pool_id: ID,
        fee_rate_numerator: u64,
        fee_rate_denominator: u64,
        fee_recipient: address,
    }

    struct UpdateConfigEvent has copy, drop {
        prev_version: u64,
        version: u64,
        prev_enabled: bool,
        enabled: bool,
        updated_at: u64,
    }    

    const InvalidBaseWeightErr: u64 = 0x1;
    const InvalidMinStakeOrMaxStakeErr: u64 = 0x2;
    const AddOrTakeRewardShouldBeMoreThanZeroErr: u64 = 0x3;

    public entry fun create_incentive_pools(
        _: &AdminCap,
        ctx: &mut TxContext,
    ) {
        abort 0
    }

    public entry fun add_points<PoolType, RewardType>(
        _: &AdminCap,
        incentive_pools: &mut IncentivePools,
        base_weight: u64,
        point_distribution_time: u64,
        incentive_duration: u64,
        new_points: u64,
        clock: &Clock,
    ) {
        abort 0
    }

    #[allow(unused_type_parameter)]
    public entry fun update_incentive_pool_params<PoolType>(
        _: &AdminCap,
        _incentive_pools: &mut IncentivePools,
        _min_stakes: u64,
        _max_stakes: u64,
        _ctx: &mut TxContext,
    ) {
        abort app_error::deprecated()
    }

    // update incentive pool params will update the min_stakes and max_stakes
    // when the pool never been initialized, it will initialize the pool with the min_stakes and max_stakes
    public entry fun update_incentive_pool_params_v2<PoolType>(
        _: &AdminCap,
        incentive_pools: &mut IncentivePools,
        min_stakes: u64,
        max_stakes: u64,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        abort 0
    }

    public entry fun take_points<PoolType, RewardType>(
        _: &AdminCap,
        incentive_pools: &mut IncentivePools,
        point_opt: Option<u64>, // if none, it will takes all points
        clock: &Clock,
    ) {
        abort 0
    }


    public entry fun add_rewards<PoolType, RewardType>(
        incentive_pools: &mut IncentivePools,
        new_rewards: Coin<RewardType>,
    ) {
        abort 0
    }

    public fun take_rewards<PoolType, RewardType>(
        _: &AdminCap,
        incentive_pools: &mut IncentivePools,
        amount: u64,
        ctx: &mut TxContext,
    ): Coin<RewardType> {
        abort 0
    }

    public entry fun update_reward_fee_pool_config(
        _: &AdminCap,
        incentive_pools: &mut IncentivePools,
        fee_rate_numerator: u64,
        fee_rate_denominator: u64,
        fee_recipient: address,
    ) {
        abort 0
    }

    public entry fun upgrade_version(
        _: &AdminCap,
        incentive_config: &mut IncentiveConfig,
        clock: &Clock,
    ) {
        abort 0
    }

    public entry fun enable(
        _: &AdminCap,
        incentive_config: &mut IncentiveConfig,
        clock: &Clock,
    ) {
        abort 0
    }

    public entry fun disable(
        _: &AdminCap,
        incentive_config: &mut IncentiveConfig,
        clock: &Clock,
    ) {
        abort 0
    }
}