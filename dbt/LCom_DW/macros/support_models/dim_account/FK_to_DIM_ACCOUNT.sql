{% macro FK_to_DIM_ACCOUNT()  %}



 {{ create_FK(target.database,"licensing","dim_license_order_school","organization_school_id",model.schema,model.name, "account_id") }}
 {{ create_FK(target.database,"licensing","dim_license_order_school","organization_district_id",model.schema,model.name, "account_id") }}
 {{ create_FK(target.database,"licensing","fact_license_order","organization_district_id",model.schema,model.name, "account_id") }}
 {{ create_FK(target.database,"licensing","fact_license_order_history","organization_district_id",model.schema,model.name, "account_id")   }}               
 {{ create_FK(target.database,"revenue","fact_opportunity","account_id",model.schema,model.name, "account_id") }}
 {{ create_FK(target.database,"revenue","fact_opportunity_history","account_id",model.schema,model.name, "account_id")    }}
 {{ create_FK(target.database,"content_delivery_usage","fact_launches_monthly_snapshots","organization_district_id",model.schema,model.name, "account_id") }}
 {{ create_FK(target.database,"content_delivery_usage","fact_launches_weekly_snapshots","organization_district_id",model.schema,model.name, "account_id")   }}                                
 {{ create_FK(target.database,"content_delivery_usage","fact_launches_monthly_snapshots","organization_school_id",model.schema,model.name, "account_id") }}
 {{ create_FK(target.database,"content_delivery_usage","fact_launches_weekly_snapshots","organization_school_id",model.schema,model.name, "account_id")   }}                           


{% endmacro  %}