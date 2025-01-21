#[allow(unused_const, unused_type_parameter, unused_field, unused_use, unused_variable)]
module borrow_incentive::incentive_account {
    use std::type_name::{Self, TypeName};
    use std::vector;
    use std::option::{Self, Option};

    use sui::balance::{Self, Balance};
    use sui::object::{Self, UID, ID};
    use sui::tx_context::TxContext;
    use sui::table::{Self, Table};
    use sui::vec_set::{Self, VecSet};
    use sui::clock::Clock;
    use sui::transfer;

    use borrow_incentive::utils::mul_div;

    use borrow_incentive::incentive_pool::{Self, IncentivePools, IncentivePool};
    use borrow_incentive::typed_id::{Self, TypedID};

    use protocol::obligation::{Self, Obligation, ObligationKey};
    use protocol::market::Market;
    use protocol::lock_obligation;
    use protocol::obligation_access::ObligationAccessStore;

    use ve_sca::ve_sca::VeScaKey;

    use coin_decimals_registry::coin_decimals_registry::CoinDecimalsRegistry;
    use x_oracle::x_oracle::XOracle;

    friend borrow_incentive::user;
    friend borrow_incentive::admin;

    const ObligationIsLockedByOtherModuleErr: u64 = 0x1;
    const ObligationIsAlreadyLockedErr: u64 = 0x2;
    const IncentivePoolsIsntUpToDate: u64 = 0x3;
    const IncentivePoolsDoesntMatch: u64 = 0x4;
    const WeightedAmountShouldBeZeroErr: u64 = 0x5;

    struct IncentiveProgramLockKey has drop { }

    // earning weight for events
    struct EarningWeightData has store, copy, drop {
        coin_type: TypeName,
        weighted_amount: u64,
    }

    // pool records for events
    struct PoolRecordData has store, copy, drop {
        pool_type: TypeName,
        earning_weights: vector<EarningWeightData>,
        debt_amount: u64,
    }

    struct PoolPoint has store {
        weighted_amount: u64,
        /// the current user point
        points: u64,
        /// total points that user already got from the pool
        total_points: u64,
        index: u64,
    }

    struct AccountPoolRecord has store {
        pool_type: TypeName,
        points: Table<TypeName, PoolPoint>,
        points_list: vector<TypeName>,
        amount: u64,
    }

    struct IncentiveAccount has key, store {
        id: UID,
        pool_records: Table<TypeName, AccountPoolRecord>,
        pool_types: VecSet<TypeName>,
        binded_ve_sca_key: Option<TypedID<VeScaKey>>,
    }

    struct IncentiveAccounts has key {
        id: UID,
        accounts: Table<TypedID<Obligation>, IncentiveAccount>,
        incentive_pools_id: ID,
    }

    public fun assert_incentive_pools(incentive_accounts: &IncentiveAccounts, incentive_pools: &IncentivePools) { 
        assert!(incentive_accounts.incentive_pools_id == object::id(incentive_pools), IncentivePoolsDoesntMatch);
    }
    
    public fun is_incentive_account_exist(incentive_accounts: &IncentiveAccounts, obligation: &Obligation): bool { table::contains(&incentive_accounts.accounts, typed_id::new(obligation)) }
    public fun incentive_account(incentive_accounts: &IncentiveAccounts, obligation: &Obligation): &IncentiveAccount { table::borrow(&incentive_accounts.accounts, typed_id::new(obligation)) }

    public fun account_pool_record(incentive_account: &IncentiveAccount, pool_type: TypeName): &AccountPoolRecord { table::borrow(&incentive_account.pool_records, pool_type) }
    public fun pool_types(incentive_account: &IncentiveAccount): VecSet<TypeName> { incentive_account.pool_types }

    public fun point_list(account_pool_record: &AccountPoolRecord): &vector<TypeName> { &account_pool_record.points_list }
    public fun pool_point(account_pool_record: &AccountPoolRecord, point_type: TypeName): &PoolPoint { table::borrow(&account_pool_record.points, point_type) }
    public fun pool_type(account_pool_record: &AccountPoolRecord): TypeName { account_pool_record.pool_type }
    public fun amount(account_pool_record: &AccountPoolRecord): u64 { account_pool_record.amount }
    public fun weighted_amount(incentive_point: &PoolPoint): u64 { incentive_point.weighted_amount }
    public fun points(incentive_point: &PoolPoint): u64 { incentive_point.points }
    public fun total_points(incentive_point: &PoolPoint): u64 { incentive_point.total_points }
    public fun index(incentive_point: &PoolPoint): u64 { incentive_point.index }

    public fun is_ve_sca_key_binded(
        incentive_accounts: &IncentiveAccounts,
        obligation: &Obligation,
    ): bool {
        abort 0
    }

    public fun get_binded_ve_sca(
        incentive_accounts: &IncentiveAccounts,
        obligation: &Obligation,
    ): TypedID<VeScaKey> {
        abort 0
    }

    public fun pool_records_data(incentive_accounts: &IncentiveAccounts, obligation: &Obligation): vector<PoolRecordData> { 
        abort 0
    }
}