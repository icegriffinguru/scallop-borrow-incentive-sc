#[allow(unused_const, unused_type_parameter, unused_field, unused_use, unused_variable, unused_mut_parameter)]
module borrow_incentive::user {
    use std::type_name::{Self, TypeName};

    use sui::tx_context::{Self, TxContext};
    use sui::clock::{Self, Clock};
    use sui::event::emit;
    use sui::object::{Self, ID};
    use sui::balance;
    use sui::coin::{Self, Coin};
    use sui::transfer;

    use {Self, IncentivePools};
    use {Self, IncentiveAccounts, PoolRecordData};
    use borrow_incentive::utils::mul_div;
    use borrow_incentive::typed_id;
    use {Self, IncentiveConfig};
    use borrow_incentive::incentive_pool;
    use borrow_incentive::incentive_config;
    use borrow_incentive::incentive_account;

    use protocol::market::Market;
    use protocol::obligation::{Self, Obligation, ObligationKey};
    use protocol::obligation_access::ObligationAccessStore;

    use ve_sca::ve_sca::{Self, VeScaKey, VeScaTable};
    use ve_sca::config::VeScaProtocolConfig;
    use ve_sca::treasury::{Self as ve_sca_treasury, VeScaTreasury};

    use coin_decimals_registry::coin_decimals_registry::CoinDecimalsRegistry;
    use x_oracle::x_oracle::XOracle;

    struct IncentiveAccountUnstakeEvent has copy, drop {
        obligation_id: ID,
        sender: address,
        timestamp: u64,
    }

    struct IncentiveAccountStakeEvent has copy, drop {
        obligation_id: ID,
        pool_records: vector<PoolRecordData>,
        timestamp: u64,
    }

    struct IncentiveAccountRedeemRewardsEvent has copy, drop {
        sender: address,
        rewards_type: TypeName,
        rewards: u64,
        rewards_fee: u64,
        timestamp: u64,
    }

    struct RefreshInactiveBoostEvent has copy, drop {
        obligation_id: ID,
        sender: address,
        timestamp: u64,
    }    

    struct DeactivateBoostEvent has copy, drop {
        obligation_id: ID,
        ve_sca_key: ID,
        sender: address,
        timestamp: u64,
    }

    const VeScaAlreadyBindedErr: u64 = 0x1;
    const IncentiveAccountBindedToAnotherVeScaErr: u64 = 0x2;
    const IncentiveAccountIsBindedToVeScaErr: u64 = 0x3;
    const IncentiveAccountIsntBindedToAnyVeScaErr: u64 = 0x4;
    const BoostIsStillActiveErr: u64 = 0x5;
    const VeScaKeyDidntMatchErr: u64 = 0x6;

    public entry fun update_points(
        incentive_config: &IncentiveConfig,
        incentive_pools: &mut IncentivePools,
        incentive_accounts: &mut IncentiveAccounts,
        obligation: &Obligation,
        clock: &Clock,
    ) {
        abort 0
    }

    public entry fun stake_with_ve_sca(
        incentive_config: &IncentiveConfig,
        incentive_pools: &mut IncentivePools,
        incentive_accounts: &mut IncentiveAccounts,
        obligation_key: &ObligationKey,
        obligation: &mut Obligation,
        obligation_access_store: &ObligationAccessStore,
        ve_sca_config: &VeScaProtocolConfig,
        ve_sca_treasury: &mut VeScaTreasury,
        ve_sca_table: &VeScaTable,        
        ve_sca_key: &VeScaKey,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        assert_version_and_status(incentive_config);
        assert_incentive_pools(incentive_accounts, incentive_pools);
        assert_key_match(obligation, obligation_key);
        create_if_not_exists(incentive_accounts, obligation, ctx);

        let ve_sca_key_id = type_id::new<VeScaKey>(ve_sca_key);
        if (is_ve_sca_key_binded(incentive_accounts, obligation) == false) {
            assert!(is_ve_sca_binded(incentive_pools, ve_sca_key_id) == false, 1);
            bind_ve_sca_to_incentive_account(incentive_pools, ve_sca_key_id, type_id::new<Obligation>(obligation));
            bind_ve_sca(incentive_accounts, obligation, ve_sca_key_id);
        };
        assert!(type_id::to_id<VeScaKey>(get_binded_ve_sca(incentive_accounts, obligation)) == type_id::to_id<VeScaKey>(ve_sca_key_id), 2);
        update_points_internal(incentive_pools, incentive_accounts, obligation, clock);
        refresh(ve_sca_config, ve_sca_treasury, clock);
        stake(
            obligation_key,
            obligation,
            obligation_access_store,
            incentive_accounts,
            incentive_pools,
            ve_sca_amount(sui::object::id<VeScaKey>(ve_sca_key), ve_sca_table, clock),
            total_ve_sca_amount(ve_sca_treasury, clock),
            ctx
        );
        let v1 = IncentiveAccountStakeEvent{
            obligation_id : sui::object::id<Obligation>(obligation), 
            pool_records  : pool_records_data(incentive_accounts, obligation), 
            timestamp     : sui::clock::timestamp_ms(clock) / 1000,
        };
        sui::event::emit<IncentiveAccountStakeEvent>(v1);
    }

    public entry fun stake(
        incentive_config: &IncentiveConfig,
        incentive_pools: &mut IncentivePools,
        incentive_accounts: &mut IncentiveAccounts,
        obligation_key: &ObligationKey,
        obligation: &mut Obligation,
        obligation_access_store: &ObligationAccessStore,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        abort 0
    }

    public entry fun unstake(
        incentive_config: &incentive_config::IncentiveConfig,
        incentive_pools: &mut incentive_pool::IncentivePools,
        incentive_accounts: &mut incentive_account::IncentiveAccounts,
        obligation_key: &obligation::ObligationKey,
        obligation: &mut obligation::Obligation,
        clock: &sui::clock::Clock,
        ctx: &mut sui::tx_context::TxContext
    ) {
        incentive_config::assert_version_and_status(incentive_config);
        incentive_account::assert_incentive_pools(incentive_accounts, incentive_pools);
        obligation::assert_key_match(obligation, obligation_key);
        if (!incentive_account::is_incentive_account_exist(incentive_accounts, obligation)) {
            return
        };
        if (incentive_account::is_ve_sca_key_binded(incentive_accounts, obligation) == true) {
            incentive_pool::unbind_ve_sca_from_incentive_account(incentive_pools, incentive_account::get_binded_ve_sca(incentive_accounts, obligation), typed_id::new<obligation::Obligation>(obligation));
            incentive_account::unbind_ve_sca(incentive_accounts, obligation);
        };
        update_points_internal(incentive_pools, incentive_accounts, obligation, clock);
        incentive_account::unstake(obligation_key, obligation, incentive_accounts, incentive_pools);

        let v0 = IncentiveAccountUnstakeEvent{
            obligation_id : sui::object::id<obligation::Obligation>(obligation), 
            sender        : sui::tx_context::sender(ctx), 
            timestamp     : sui::clock::timestamp_ms(clock) / 1000,
        };
        sui::event::emit<IncentiveAccountUnstakeEvent>(v0);
    }

    public entry fun force_unstake_unhealthy(
        incentive_config: &IncentiveConfig,
        incentive_pools: &mut IncentivePools,
        incentive_accounts: &mut IncentiveAccounts,
        obligation: &mut Obligation,
        market: &mut Market,
        coin_decimals_registry: &CoinDecimalsRegistry,
        x_oracle: &XOracle,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        abort 0
    }

    public entry fun refresh_inactive_boost(
        incentive_config: &IncentiveConfig,
        incentive_pools: &mut IncentivePools,
        incentive_accounts: &mut IncentiveAccounts,
        ve_sca_table: &VeScaTable,
        obligation: &mut Obligation,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        abort 0
    }

    /// the owner of the ve_sca can deactivate their boost for binded incentive_account
    /// the owner ve_sca have right to remove boosted APR from an incentive account
    public fun deactivate_boost(
        incentive_config: &IncentiveConfig,
        incentive_pools: &mut IncentivePools,
        incentive_accounts: &mut IncentiveAccounts,
        obligation: &Obligation,
        ve_sca_key: &VeScaKey,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        abort 0
    }

    public fun redeem_rewards<RewardType>(
        incentive_config: &IncentiveConfig,
        incentive_pools: &mut IncentivePools,
        incentive_accounts: &mut IncentiveAccounts,
        obligation_key: &ObligationKey,
        obligation: &Obligation,
        clock: &Clock,
        ctx: &mut TxContext,
    ): Coin<RewardType> {
        abort 0
    }
}