/*
stg_contracts.sql
Staging model for raw USASpending.gov contract data.
Cleans column names, casts types, and filters nulls.
*/

with source as (

    select * from read_csv_auto(
        '/home/taylo/logistics-etl-pipeline/data/raw/contracts_raw.csv'
    )

),

renamed as (

    select
        "Award ID"                          as award_id,
        "Recipient Name"                    as recipient_name,
        cast("Award Amount" as double)      as award_amount,
        cast("Total Outlays" as double)     as total_outlays,
        "Description"                       as description,
        cast("Start Date" as date)          as start_date,
        cast("End Date" as date)            as end_date,
        "Awarding Agency"                   as awarding_agency,
        "Awarding Sub Agency"               as awarding_sub_agency,
        "Place of Performance State Code"   as performance_state

    from source

),

cleaned as (

    select *
    from renamed
    where award_id is not null
      and recipient_name is not null
      and award_amount > 0

)

select * from cleaned
