version: 2

models:
  - name: dim_arr_audit
    description: >

      Bridge dimension that maps audited ARR issues to opportunities by month.
      It links opportunity_id with issue_id from dim_arr_issue

      This model allows reporting on ARR quality calculation at the level of a specific issue, opportunity and month.

    config:
      contract:
        enforced: true
      tags:
        - dim
        - revenue
        - arr

    data_tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - mon_year
            - opportunity_id
            - issue_id

    columns:
      - name: mon_year
        description: >
          Accounting month in YYYYMM integer format derived from the audited opportunity start date.
          Used to align opportunity issues to ARR reporting periods.
        data_type: integer
        constraints:
          - type: not_null

      - name: opportunity_id
        description: "{{ doc('column_opportunity_id') }}"
        data_type: varchar(300)
        constraints:
          - type: not_null
        data_tests:
          - relationships:
              to: ref('fact_opportunity')
              field: opportunity_id

      - name: issue_id
        description: >
          Surrogate key of the ARR audit issue category.
          Links this bridge table to dim_arr_issue for issue reporting and grouping.
        data_type: varchar(50)
        constraints:
          - type: not_null
        data_tests:
          - relationships:
              to: ref('dim_arr_issue')
              field: issue_id