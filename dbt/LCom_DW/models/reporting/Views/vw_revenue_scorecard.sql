{{ config(materialized='view',
   bind=False
)
 }}
with month_params as (
    select
        to_char(getdate(), 'yyyymm')::int as current_mon,
        to_char(dateadd(month, -11, getdate()), 'yyyymm')::int as current_window_start,
        to_char(dateadd(month, -12, getdate()), 'yyyymm')::int as previous_mon,
        to_char(dateadd(month, -23, getdate()), 'yyyymm')::int as previous_window_start,
        to_char(dateadd(month, -24, getdate()), 'yyyymm')::int as previous_base_mon
),

opportunities_data as (
    select 
        fa.arr_type, 
        fa.mon_year, 
        fa.record_type, 
        fa.bucket, 
        fa.opportunity_id,
        dsp.sfdc_product_sub_family,
        sum(fa.arr_amount) as arr_amount,
        max(fa.loaddate) as loaddate
    from {{ ref('fact_arr') }} fa
    join {{ ref("dim_sfdc_product") }} dsp on fa.sfdc_product_id = dsp.sfdc_product_id
    cross join month_params mp
    where getdate() between fa.arr_activation_date and fa.arr_deactivation_date
      and fa.mon_year between mp.previous_base_mon and mp.current_mon
    group by
        fa.arr_type, 
        fa.mon_year, 
        fa.record_type, 
        fa.bucket, 
        fa.opportunity_id,
        dsp.sfdc_product_sub_family
),

rawdata as (
    select
        arr_type,
        mon_year,

        sum(case 
            when record_type = 'ARR' 
            then arr_amount 
            else 0 
        end) as arr,

        sum(case 
            when record_type = 'ARR-MonthlyReduced'
              or (record_type = 'ARR-MonthlyAdded' and arr_amount < 0)
            then arr_amount 
            else 0 
        end) as arr_monthly_reduced,

        sum(case 
            when record_type = 'ARR-MonthlyAdded'
             and (bucket ilike '%upsell%' or (bucket ilike '%placeholder%' and arr_amount>0))
            then arr_amount 
            else 0 
        end) as arr_monthly_upsell,

        max(loaddate) as loaddate
    from opportunities_data
    group by
        arr_type,
        mon_year
),

category_windows as (
    select
        'Actual' as category,
        current_mon as arr_mon,
        previous_mon as base_mon,
        current_window_start as movement_start_mon,
        current_mon as movement_end_mon
    from month_params

    union all

    select
        'Previous' as category,
        previous_mon as arr_mon,
        previous_base_mon as base_mon,
        previous_window_start as movement_start_mon,
        previous_mon as movement_end_mon
    from month_params
),

data as (
    select
        cw.category,
        r.arr_type,

        sum(case 
            when r.mon_year = cw.arr_mon 
            then r.arr 
            else 0 
        end) as arr,

        sum(case 
                when r.mon_year = cw.base_mon 
                then r.arr 
                else 0 
            end) as arr_base,

        sum(case 
                when r.mon_year between cw.movement_start_mon and cw.movement_end_mon
                then r.arr_monthly_reduced 
                else 0 
            end) as arr_movement_reduced,

        sum(case 
                when r.mon_year between cw.movement_start_mon and cw.movement_end_mon
                then r.arr_monthly_upsell 
                else 0 
            end) as arr_movement_upsell,


        (
            sum(case 
                when r.mon_year = cw.base_mon 
                then r.arr 
                else 0 
            end)
            +
            sum(case 
                when r.mon_year between cw.movement_start_mon and cw.movement_end_mon
                then r.arr_monthly_reduced 
                else 0 
            end)
        )
        /
        nullif(
            sum(case 
                when r.mon_year = cw.base_mon 
                then r.arr 
                else 0 
            end)::float,
            0
        ) as gdr,

        (
            sum(case 
                when r.mon_year = cw.base_mon 
                then r.arr 
                else 0 
            end)
            +
            sum(case 
                when r.mon_year between cw.movement_start_mon and cw.movement_end_mon
                then r.arr_monthly_reduced 
                else 0 
            end)
            +
            sum(case 
                when r.mon_year between cw.movement_start_mon and cw.movement_end_mon
                then r.arr_monthly_upsell 
                else 0 
            end)
        )
        /
        nullif(
            sum(case 
                when r.mon_year = cw.base_mon 
                then r.arr 
                else 0 
            end)::float,
            0
        ) as nrr,

        max(case 
            when r.mon_year = cw.arr_mon 
            then r.loaddate 
        end) as loaddate

    from rawdata r
    cross join category_windows cw
    group by
        cw.category,
        r.arr_type
        
        union all
        
   select 
    'Target' as category,
    'Target' as arr_type,    
    26400000 as arr,
    0 as arr_base,
    0 as arr_movement_reduced,
    0 as arr_movement_upsell,
    1 as gdr,
    0.9 as nrr,
    cast('1900-01-01' as date) loaddate
        
        
)

select 
    category,
    arr_type,
    arr,
    arr_base,
    arr_movement_reduced,
    arr_movement_upsell,
    gdr,
    nrr,
    loaddate as last_updated
from data
order by 
    category,
    arr_type