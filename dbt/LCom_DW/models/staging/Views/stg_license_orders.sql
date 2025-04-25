{{ config(materialized='view', 
   bind=False, 
   description="The staging view filter EXCLUDES: COVID19 orders,  Google Integration, Generic LTI Tool Consumer, Tech Apps TCEA Assessment MS 19/20+ SKUs and NOT valid orders."
   ) }}

select * from {{ source("staging","license_order") }} stg
where
stg.Valid_boolean=true and
stg.NetSuiteOrderId != 'COVID19' and
stg.SkuId NOT IN ('63CC161C-A834-4017-8281-ED0C4C4C52B5' --Google Integration
                 ,'CA3A733E-0F33-4918-897B-506C6BD6907C' --Generic LTI Tool Consumer
                 ,'545DA6FB-B65D-4EA8-A374-30BEEAAA28D4' --Tech Apps TCEA Assessment MS 19/20+'
                           )