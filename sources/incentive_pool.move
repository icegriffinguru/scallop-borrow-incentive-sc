#[allow(unused_const, unused_type_parameter, unused_field, unused_use, unused_variable)]
module borrow_incentive::incentive_pool {
    
    use std::type_name::{Self, TypeName};
    use std::vector;
    use std::option::{Self, Option};
    use sui::clock::{Self, Clock};
    use sui::object::{Self, UID};
    use sui::table::{Self, Table};
    use sui::vec_set::{Self, VecSet};
    use sui::math;
    use sui::transfer;
    use sui::tx_context::TxContext;
    use sui::balance::{Self, Balance};
    use sui::bag::{Self, Bag};
    use borrow_incentive::typed_id::{Self, TypedID};
    use borrow_incentive::app_error;
    use borrow_incentive::utils::mul_div;

    use ve_sca::ve_sca::VeScaKey;
    use protocol::obligation::Obligation;

    friend borrow_incentive::incentive_account;
    friend borrow_incentive::admin;
    friend borrow_incentive::user;

    const MaxStakesReachedLimitErr: u64 = 0x1;
    const ObligationNotMatchedErr: u64 = 0x2;

    struct IncentivePoolPoint has store {
        /// points that will be distribute on every period
        distributed_point_per_period: u64,
        /// what is the duration before the point distribute for the next time
        point_distribution_time: u64,
        /// distributed reward that is already belong to users
        distributed_point: u64,
        points: u64,
        base_weight: u64,
        weighted_amount: u64,
        index: u64,
        last_update: u64,
        created_at: u64,
    }

    struct IncentivePool has store {
        pool_type: TypeName,
        points: Table<TypeName, IncentivePoolPoint>,
        points_list: vector<TypeName>,
        // if stakes less than min_stakes, it will not generated any rewards
        min_stakes: u64,
        // if stakes reached max_stakes, new user can't join that particular pool
        max_stakes: u64,
        stakes: u64,
    }
    
    struct IncentivePools has key {
        id: UID,
        pools: Table<TypeName, IncentivePool>,
        pool_types: VecSet<TypeName>,
        rewards: Table<TypeName, Bag>,
        reward_fee_numerator: u64,
        reward_fee_denominator: u64,
        reward_fee_recipient: Option<address>,
        ve_sca_bind: Table<TypedID<VeScaKey>, TypedID<Obligation>>, // ve_sca_id -> obligation_id
    }

    const BaseIndexRate: u64 = 1_000_000_000;
    public fun base_index_rate(): u64 { BaseIndexRate }

    const WeightScale: u64 = 1_000_000_000_000; // 100%
    public fun weight_scale(): u64 { WeightScale }

    public fun incentive_pool(incentive_pools: &IncentivePools, pool_type: TypeName): &IncentivePool { table::borrow(&incentive_pools.pools, pool_type) }

    public fun is_pool_exist(
        incentive_pools: &IncentivePools,
        pool_type: TypeName
    ): bool { table::contains(&incentive_pools.pools, pool_type) }

    public fun pool_types(incentive_pools: &IncentivePools): VecSet<TypeName> { incentive_pools.pool_types }
    public fun pools(incentive_pools: &IncentivePools): &Table<TypeName, IncentivePool> { &incentive_pools.pools }
    
    public fun remaining_rewards<RewardType>(incentive_pools: &IncentivePools, pool_coin_type: TypeName): u64 {
        let bag = table::borrow(&incentive_pools.rewards, pool_coin_type);
        let balance = bag::borrow<TypeName, Balance<RewardType>>(bag, type_name::get<RewardType>());
        balance::value(balance)
    }

    public fun points_list(incentive_pool: &IncentivePool): &vector<TypeName> { &incentive_pool.points_list }
    public fun pool_point(incentive_pool: &IncentivePool, coin_type: TypeName): &IncentivePoolPoint { table::borrow(&incentive_pool.points, coin_type) }
    public fun pool_type(incentive_pool: &IncentivePool): TypeName { incentive_pool.pool_type }
    public fun distributed_point_per_period(incentive_pool_point: &IncentivePoolPoint): u64 { incentive_pool_point.distributed_point_per_period }
    public fun point_distribution_time(incentive_pool_point: &IncentivePoolPoint): u64 { incentive_pool_point.point_distribution_time }
    public fun distributed_point(incentive_pool_point: &IncentivePoolPoint): u64 { incentive_pool_point.distributed_point }
    public fun points(incentive_pool_point: &IncentivePoolPoint): u64 { incentive_pool_point.points }
    public fun last_update(incentive_pool_point: &IncentivePoolPoint): u64 { incentive_pool_point.last_update }
    public fun base_weight(incentive_pool_point: &IncentivePoolPoint): u64 { incentive_pool_point.base_weight }
    public fun index(incentive_pool_point: &IncentivePoolPoint): u64 { incentive_pool_point.index }
    public fun weighted_amount(incentive_pool_point: &IncentivePoolPoint): u64 { incentive_pool_point.weighted_amount }
    public fun created_at(incentive_pool: &IncentivePoolPoint): u64 { incentive_pool.created_at }
    public fun min_stakes(incentive_pool: &IncentivePool): u64 { incentive_pool.min_stakes }
    public fun max_stakes(incentive_pool: &IncentivePool): u64 { incentive_pool.max_stakes }
    public fun stakes(incentive_pool: &IncentivePool): u64 { incentive_pool.stakes }

    public fun is_points_up_to_date(
        incentive_pools: &IncentivePools,
        clock: &Clock
    ): bool {
        abort 0
    }

    public fun reward_fee(incentive_pools: &IncentivePools,): (u64, u64) {
        abort 0
    }

    public fun is_reward_fee_recipient_exist(incentive_pools: &IncentivePools): bool {
        abort 0
    }

    public fun reward_fee_recipient(
        incentive_pools: &IncentivePools,
    ): address {
        abort 0
    }

    public fun is_ve_sca_binded(
        incentive_pools: &IncentivePools,
        ve_sca_key_id: TypedID<VeScaKey>,
    ): bool {
        abort 0
    }
}