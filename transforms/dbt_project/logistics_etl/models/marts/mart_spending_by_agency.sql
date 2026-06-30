/*
mart_spending_by_agency.sql
Aggregates contract spending by awarding agency.
Built on top of stg_contracts.
*/

with contracts as (

    select * from {{ ref('stg_contracts') }}

),

aggregated as (

    select
        awarding_agency,
        awarding_sub_agency,
        count(*)                          as contract_count,
        sum(award_amount)                 as total_award_amount,
        round(avg(award_amount), 2)        as avg_award_amount,
        max(award_amount)                 as largest_award,
        min(start_date)                   as earliest_start_date,
        max(end_date)                     as latest_end_date

    from contracts
    group by awarding_agency, awarding_sub_agency

)

select * from aggregated
order by total_award_amount desc
