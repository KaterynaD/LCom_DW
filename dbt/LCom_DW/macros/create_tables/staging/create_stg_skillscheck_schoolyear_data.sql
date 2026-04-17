{% macro create_stg_skillscheck_schoolyear_data() %}
 {% set create_table_operation %}

DROP TABLE if exists staging.stg_skillscheck_schoolyear_data;
CREATE TABLE staging.stg_skillscheck_schoolyear_data
(
    schoolyear                       character varying(20)  NOT NULL,
    country_code                     character(2)           NOT NULL,
    state_province_key               character varying(6)   NULL,
    organization_district_id         character varying(255) NOT NULL,
    organization_school_id           character varying(255) NULL,
    user_account_id                  character varying(255) NOT NULL,
    user_grade_level_code            character(2)           NULL,
    assessment_set_id                integer                NOT NULL,
    level                            character varying(10)  NOT NULL,
    skill                            character varying(100) NOT NULL,
    took_both                        boolean                NOT NULL,
    pre_learning_object_id           character varying(50)  NULL,
    pre_score_datetime               timestamptz            NULL,
    pre_time_spent_seconds           integer                NULL,
    pre_time_spent_seconds_capped    integer                NULL,
    pre_score                        integer                NULL,
    pre_possible_score               integer                NULL,
    pre_pct_score                    numeric(8,6)           NULL,
    pre_performance_bucket           character varying(10)  NULL,
    post_learning_object_id          character varying(50)  NULL,
    post_score_datetime              timestamptz            NULL,
    post_time_spent_seconds          integer                NULL,
    post_time_spent_seconds_capped   integer                NULL,
    post_score                       integer                NULL,
    post_possible_score              integer                NULL,
    post_pct_score                   numeric(8,6)           NULL,
    post_performance_bucket          character varying(10)  NULL,
    score_change                     integer                NULL,
    pct_score_change                 numeric(8,6)           NULL,
    pct_growth                       numeric(8,6)           NULL,
    unique_items_completed_before    integer                NULL,
    unique_items_completed_between   integer                NULL
) DISTSTYLE AUTO
DISTKEY (organization_district_id)
SORTKEY (user_account_id, assessment_set_id);

COMMENT ON TABLE staging.stg_skillscheck_schoolyear_data IS 'Staging table to keep skills check school year data per user for pre- and post-test results';

{% endset %}

{% do run_query(create_table_operation) %}

{% endmacro %} 