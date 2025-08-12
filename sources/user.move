#[allow(unused_const, unused_type_parameter, unused_field, unused_use, unused_variable, unused_mut_parameter)]
module borrow_incentive::user {
    use std::type_name::{Self, TypeName};

    use {Self, TxContext};
    use {Self, Clock};
    use sui::event::emit;
    use sui::object::{Self, ID};
    use sui::balance;
    use sui::coin::{Self, Coin};
    use sui::transfer;

    use borrow_incentive::utils::mul_div;
    use borrow_incentive::typed_id;
    use borrow_incentive::{Self, IncentivePools};
    use borrow_incentive::{Self, IncentiveConfig};
    use borrow_incentive::{Self, IncentiveAccounts, PoolRecordData};

    use protocol::market::Market;
    use {Self, Obligation, ObligationKey};
    use ObligationAccessStore;

    use {Self, VeScaKey, VeScaTable};
    use VeScaProtocolConfig;
    use {Self as ve_sca_treasury, VeScaTreasury};

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

    /// DEPRECATED
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
        abort 0
    }

    public entry fun stake_with_ve_sca_v2(
        incentive_config: &IncentiveConfig,
        incentive_pools: &mut IncentivePools,
        incentive_accounts: &mut IncentiveAccounts,
        obligation_key: &ObligationKey,
        obligation: &mut Obligation,
        obligation_access_store: &ObligationAccessStore,
        ve_sca_protocol_config: &VeScaProtocolConfig,
        ve_sca_treasury: &mut VeScaTreasury,
        ve_sca_table: &VeScaTable,
        ve_sca_key: &VeScaKey,
        ve_sca_subscriber_table: &mut VeScaSubscriberTable,
        ve_sca_subscriber_whitelist: &VeScaSubscriberWhitelist,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        assert_version_and_status(incentive_config);
        assert_incentive_pools(incentive_accounts, incentive_pools);
        assert_key_match(obligation, obligation_key);
        create_if_not_exists(incentive_accounts, obligation, ctx);
        let v0 = typed_id::new<VeScaKey>(ve_sca_key);
        if (is_ve_sca_key_binded(incentive_accounts, obligation) == false) {
            assert!(is_ve_sca_binded(incentive_pools, v0) == false, 1);
            bind_ve_sca_to_incentive_account(incentive_pools, v0, typed_id::new<Obligation>(obligation));
            bind_ve_sca(incentive_accounts, obligation, v0);
            subscribe<IncentiveProgramVeScaSubscriberKey>(incentive_program_ve_sca_subscriber_key(), ve_sca_subscriber_table, ve_sca_subscriber_whitelist, *typed_id::as_id<VeScaKey>(&v0));
        };
        assert!(typed_id::to_id<VeScaKey>(get_binded_ve_sca(incentive_accounts, obligation)) == typed_id::to_id<VeScaKey>(v0), 2);
        update_points_internal(incentive_pools, incentive_accounts, obligation, clock);
        refresh(ve_sca_protocol_config, ve_sca_treasury, clock);
        stake(obligation_key, obligation, obligation_access_store, incentive_accounts, incentive_pools, ve_sca_amount(sui::object::id<VeScaKey>(ve_sca_key), ve_sca_table, clock), total_ve_sca_amount(ve_sca_treasury, clock), ctx);
        let v1 = IncentiveAccountStakeEvent{
            obligation_id : sui::object::id<Obligation>(obligation), 
            pool_records  : pool_records_data(incentive_accounts, obligation), 
            timestamp     : timestamp_ms(clock) / 1000,
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
        incentive_config: &IncentiveConfig,
        incentive_pools: &mut IncentivePools,
        incentive_accounts: &mut IncentiveAccounts,
        obligation_key: &obligation::ObligationKey,
        obligation: &mut obligation::Obligation,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        abort 0
    }

    public entry fun unstake_v2(
        incentive_config: &IncentiveConfig,
        incentive_pools: &mut IncentivePools,
        incentive_accounts: &mut IncentiveAccounts,
        obligation_key: &ObligationKey,
        obligation: &mut Obligation,
        ve_sca_subscriber_table: &mut VeScaSubscriberTable,
        ve_sca_subscriber_whitelist: &VeScaSubscriberWhitelist,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        assert_version_and_status(incentive_config);
        assert_incentive_pools(incentive_accounts, incentive_pools);
        assert_key_match(obligation, obligation_key);
        
        if (!is_incentive_account_exist(incentive_accounts, obligation)) {
            return
        };

        if (is_ve_sca_key_binded(incentive_accounts, obligation) == true) {
            let v0 = get_binded_ve_sca(incentive_accounts, obligation);
            unbind_ve_sca_from_incentive_account(incentive_pools, v0, typed_id::new<Obligation>(obligation));
            unbind_ve_sca(incentive_accounts, obligation);
            let v1 = *typed_id::as_id<VeScaKey>(&v0);
            if (has_subscribers(ve_sca_subscriber_table, v1)) {
                unsubscribe<IncentiveProgramVeScaSubscriberKey>(
                    incentive_program_ve_sca_subscriber_key(),
                    ve_sca_subscriber_table,
                    ve_sca_subscriber_whitelist,
                    v1
                );
            };
        };

        update_points_internal(incentive_pools, incentive_accounts, obligation, clock);
        unstake(obligation_key, obligation, incentive_accounts, incentive_pools);
        let v2 = IncentiveAccountUnstakeEvent{
            obligation_id : sui::object::id<Obligation>(obligation), 
            sender        : sender(ctx), 
            timestamp     : timestamp_ms(clock) / 1000,
        };
        sui::event::emit<IncentiveAccountUnstakeEvent>(v2);
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

    public entry fun force_unstake_unhealthy_v2(arg0: &IncentiveConfig, arg1: &mut IncentivePools, arg2: &mut IncentiveAccounts, arg3: &mut Obligation, arg4: &mut protocol::market::Market, arg5: &0xca5a5a62f01c79a104bf4d31669e29daa387f325c241de4edbe30986a9bc8b0d::coin_decimals_registry::CoinDecimalsRegistry, arg6: &0x1478a432123e4b3d61878b629f2c692969fdb375644f1251cd278a4b1e7d7cd6::x_oracle::XOracle, arg7: &mut VeScaSubscriberTable, arg8: &VeScaSubscriberWhitelist, arg9: &Clock, arg10: &mut TxContext) {
        assert_version_and_status(arg0);
        assert_incentive_pools(arg2, arg1);
        if (!is_incentive_account_exist(arg2, arg3)) {
            return
        };
        if (is_ve_sca_key_binded(arg2, arg3) == true) {
            let v0 = get_binded_ve_sca(arg2, arg3);
            unbind_ve_sca_from_incentive_account(arg1, v0, typed_id::new<Obligation>(arg3));
            unbind_ve_sca(arg2, arg3);
            let v1 = *typed_id::as_id<VeScaKey>(&v0);
            if (has_subscribers(arg7, v1)) {
                unsubscribe<IncentiveProgramVeScaSubscriberKey>(incentive_program_ve_sca_subscriber_key(), arg7, arg8, v1);
            };
        };
        update_points_internal(arg1, arg2, arg3, arg9);
        force_unstake_unhealthy(arg3, arg2, arg1, arg4, arg5, arg6, arg9);
        let v2 = IncentiveAccountUnstakeEvent{
            obligation_id : sui::object::id<Obligation>(arg3), 
            sender        : sender(arg10), 
            timestamp     : timestamp_ms(arg9) / 1000,
        };
        sui::event::emit<IncentiveAccountUnstakeEvent>(v2);
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

    public fun deactivate_boost_v2(arg0: &IncentiveConfig, arg1: &mut IncentivePools, arg2: &mut IncentiveAccounts, arg3: &Obligation, arg4: &VeScaKey, arg5: &mut VeScaSubscriberTable, arg6: &VeScaSubscriberWhitelist, arg7: &Clock, arg8: &mut TxContext) {
        assert_version_and_status(arg0);
        assert_incentive_pools(arg2, arg1);
        if (!is_incentive_account_exist(arg2, arg3)) {
            return
        };
        update_points_internal(arg1, arg2, arg3, arg7);
        assert!(is_ve_sca_key_binded(arg2, arg3) == true, 4);
        let v0 = get_binded_ve_sca(arg2, arg3);
        assert!(*typed_id::as_id<VeScaKey>(&v0) == sui::object::id<VeScaKey>(arg4), 6);
        unbind_ve_sca_from_incentive_account(arg1, v0, typed_id::new<Obligation>(arg3));
        unbind_ve_sca(arg2, arg3);
        let v1 = *typed_id::as_id<VeScaKey>(&v0);
        if (has_subscribers(arg5, v1)) {
            unsubscribe<IncentiveProgramVeScaSubscriberKey>(incentive_program_ve_sca_subscriber_key(), arg5, arg6, v1);
        };
        recalculate_stake(arg3, arg2, arg1, 0, 0, arg8);
        let v2 = DeactivateBoostEvent{
            obligation_id : sui::object::id<Obligation>(arg3), 
            ve_sca_key    : sui::object::id<VeScaKey>(arg4), 
            sender        : sender(arg8), 
            timestamp     : timestamp_ms(arg7) / 1000,
        };
        sui::event::emit<DeactivateBoostEvent>(v2);
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

    fun update_points_internal(
        arg0: &mut IncentivePools,
        arg1: &mut IncentiveAccounts,
        arg2: &Obligation,
        arg3: &0x2::clock::Clock
    ) {
        assert_incentive_pools(arg1, arg0);
        accrue_all_points(arg0, arg3);
        accrue_all_points(arg0, arg1, arg2, arg3);
    }
}