version: 2

models:
  - name: stg_all_opportunities_contacts
    description: >
      Staging model that explodes Salesforce opportunities to opportunity-contact rows.
      Produces one row per (opportunity_id, contact_id) for the primary contact and up to three additional
      contacts (x_1_st_contact, x_2_nd_contact, x_3_rd_contact) from fact_opportunity.
      Filtered to opportunities created after 2023-06-30 and excludes contacts equal to {{ var("default_ID") }}.
      Used downstream by dim_contact and marketing contacts fact tables.
    config:
      tags:
        - staging
        - marketing  

    columns:
      - name: opportunity_id
        data_type: varchar(300)
        description: Primary Key of FACT_OPPORTUNITY. It`s Salesforce Opportunity ID column

      - name: contact_id
        data_type: varchar(300)
        description: "{{ doc('column_contact_id') }}"

      - name: opp_created_date
        data_type: timestamp without time zone
        description: >
          Opportunity created date (renamed from created_date in fact_opportunity).
          "{{ doc('column_created_date') }}"

      - name: opp_close_date
        data_type: date
        description: >
          Opportunity close date (renamed from close_date in fact_opportunity).
          "{{ doc('column_close_date') }}"

      - name: is_closed
        data_type: boolean
        description: >
          Derived flag: TRUE when opportunity stage_name indicates a closed stage
  

      - name: is_won
        data_type: boolean
        description: >
          Derived flag: TRUE when opportunity stage_name indicates a won stage.
          and invoiced_date != {{ var("default_date") }}.


      - name: opp_amount
        data_type: numeric(35,10)
        description: >
          Opportunity amount (renamed from amount in fact_opportunity).
          "{{ doc('column_amount') }}"

      - name: opp_type
        data_type: varchar(20)
        description: >
          Opportunity record type (renamed from opp_record_type in fact_opportunity).
          "{{ doc('column_opp_record_type') }}"

      - name: campaign_id
        data_type: varchar(300)
        description: "{{ doc('column_campaign_id') }}"
