{{ config(materialized='view', 
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]   
   ) }}

select * from {{ ref("fact_license_order") }} f
where
f.Valid='Y' and
f.netsuite_order_id != 'COVID19' and
f.sku_id NOT IN ('63CC161C-A834-4017-8281-ED0C4C4C52B5' --Google Integration
                 ,'CA3A733E-0F33-4918-897B-506C6BD6907C' --Generic LTI Tool Consumer
                 ,'545DA6FB-B65D-4EA8-A374-30BEEAAA28D4' --Tech Apps TCEA Assessment MS 19/20+'
                           )