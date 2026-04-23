{% macro create_load_skillscheck_schoolyear_data() %}
 {% set create_sp_operation %}


CREATE OR REPLACE PROCEDURE {{target.database}}.{{target.schema}}.load_skillscheck_schoolyear_data(ploaddate timestamp)
	LANGUAGE plpgsql
AS $$

DECLARE v_start_date date;
        v_end_date   date;
        v_curr_sy_start date;
        v_assessment_type char(3) := 'SBA';

BEGIN	

    SELECT schoolyear_startdate INTO v_curr_sy_start
    FROM  {{ ref("dim_calendar") }}
    WHERE cal_date = ploaddate::date;
    
    IF ploaddate::date = v_curr_sy_start THEN
        -- It's the first day of the school year
        -- Range: [First day of previous school year] to < [First day of current school year]
        v_start_date := v_curr_sy_start - INTERVAL '1 year';
        v_end_date   := v_curr_sy_start;
    ELSE
        -- Not the first day of the school year: Capture start of year until yesterday midnight
        -- Range: [Start of current school year] to < [Input Date]
        v_start_date := v_curr_sy_start;
        v_end_date   := ploaddate::date;
    END IF;

-- Get the first completed pretest in the school year for each student
    DROP TABLE IF EXISTS _first_pre;
    CREATE TEMP TABLE _first_pre
    (
      user_account_id           varchar(255)
    , user_grade_level_code     char(2)
    , country_code              char(2)
    , state_province_key        char(5)
    , organization_district_id  varchar(255)
    , organization_school_id    varchar(255)
    , assessment_set_id         int
    , assessment_set_name       varchar(255)
    , learning_object_id        varchar(50)
    , learning_object_name      varchar(255)
    , level                     varchar(10)
    , topic_name                varchar(100)
    , standard_topic_label      varchar(50)
    , event_aggregate_id        varchar(255)
    , event_version_number      varchar(255)
    , score_datetime            timestamptz
    , time_spent_seconds        int
    , time_spent_seconds_capped int
    , score                     decimal(8,4)
    , possible_score            decimal(8,4)
    , percentage_score          int
    , performance_bucket        varchar(50)
    );

    INSERT INTO _first_pre
    SELECT DISTINCT
        user_account_id,
        user_grade_level_code,
        country_code,
        state_province_key,
        organization_district_id,
        organization_school_id,
        assessment_set_id,
        assessment_set_name,
        learning_object_id,
        learning_object_name,
        level,
        topic_name,
        standard_topic_label,
        event_aggregate_id,
        event_version_number,
        score_datetime,
        time_spent_seconds,
        CASE -- cap excessive duration times
             WHEN time_spent_seconds > 3600 THEN 3600
             ELSE time_spent_seconds
        END AS time_spent_seconds_capped,
        score,
        possible_score,
        percentage_score,
        case when percentage_score < (cut_score_level_1 * 100) then 'Beginning'
             when percentage_score >= (cut_score_level_1 * 100) and percentage_score < (cut_score_level_2 * 100) then 'Developing'
             when percentage_score >= (cut_score_level_2 * 100) then 'Proficient'
        end AS performance_bucket
    FROM
        (
            SELECT
                fac.user_account_id,
                fac.user_grade_level_code,
                dis.country_code,
                dis.state_province_key,
                fac.organization_district_id,
                fac.organization_school_id,
                las.assessment_set_id,
                las.assessment_set_name,
                lo.learning_object_id,
                lo.learning_object_name,
                las.level,
                las.topic_name,
                las.standard_topic_label,
                fac.event_aggregate_id,
                fac.event_version_number,
                fac.score_datetime,
                fac.time_spent_seconds,
                fac.score,
                lo.possible_score,
                fac.percentage_score,
                las.cut_score_level_1,
                las.cut_score_level_2,
                ROW_NUMBER() OVER (PARTITION BY las.assessment_set_id, fac.organization_district_id, fac.user_account_id ORDER BY fac.score_datetime ASC) AS first_order
            FROM content_delivery_usage.dbo.fact_assignment_completion fac
            JOIN content_delivery_usage.dbo.organization dis ON fac.organization_district_id = dis.organization_id
            JOIN content_delivery_usage.dbo.learning_assessment_set las ON fac.learning_object_id = las.learning_object_pretest_id --PRETEST
            JOIN content_delivery_usage.dbo.learning_object lo ON fac.learning_object_id = lo.learning_object_id
            WHERE
                fac.score_datetime >= v_start_date AND fac.score_datetime < v_end_date
                AND dis.is_demo = FALSE
                AND las.assessment_type = v_assessment_type
        ) eh
    WHERE
        eh.first_order = 1;


    -- Get the last completed posttest in the school year for each student
    DROP TABLE IF EXISTS _last_post;
    CREATE TEMP TABLE _last_post
    (
      user_account_id           varchar(255)
    , user_grade_level_code     char(2)
    , country_code              char(2)
    , state_province_key        char(5)
    , organization_district_id  varchar(255)
    , organization_school_id    varchar(255)
    , assessment_set_id         int
    , assessment_set_name       varchar(255)
    , learning_object_id        varchar(50)
    , learning_object_name      varchar(255)
    , level                     varchar(10)
    , topic_name                varchar(100)
    , standard_topic_label      varchar(50)
    , event_aggregate_id        varchar(255)
    , event_version_number      varchar(255)
    , score_datetime            timestamptz
    , time_spent_seconds        int
    , time_spent_seconds_capped int
    , score                     decimal(8,4)
    , possible_score            decimal(8,4)
    , percentage_score          int
    , performance_bucket        varchar(50)
    );

    INSERT INTO _last_post
    SELECT DISTINCT
        user_account_id,
        user_grade_level_code,
        country_code,
        state_province_key,
        organization_district_id,
        organization_school_id,
        assessment_set_id,
        assessment_set_name,
        learning_object_id,
        learning_object_name,
        level,
        topic_name,
        standard_topic_label,
        event_aggregate_id,
        event_version_number,
        score_datetime,
        time_spent_seconds,
        CASE -- cap excessive duration times
             WHEN time_spent_seconds > 3600 THEN 3600
             ELSE time_spent_seconds
        END AS time_spent_seconds_capped,
        score,
        possible_score,
        percentage_score,
        case when percentage_score < (cut_score_level_1 * 100) then 'Beginning'
             when percentage_score >= (cut_score_level_1 * 100) and percentage_score < (cut_score_level_2 * 100) then 'Developing'
             when percentage_score >= (cut_score_level_2 * 100) then 'Proficient'
        end AS performance_bucket
    FROM
        (
            SELECT
                fac.user_account_id,
                fac.user_grade_level_code,
                dis.country_code,
                dis.state_province_key,
                fac.organization_district_id,
                fac.organization_school_id,
                las.assessment_set_id,
                las.assessment_set_name,
                lo.learning_object_id,
                lo.learning_object_name,
                las.level,
                las.topic_name,
                las.standard_topic_label,
                fac.event_aggregate_id,
                fac.event_version_number,
                fac.score_datetime,
                fac.time_spent_seconds,
                fac.score,
                lo.possible_score,
                fac.percentage_score,
                las.cut_score_level_1,
                las.cut_score_level_2,
                ROW_NUMBER() OVER (PARTITION BY las.assessment_set_id, fac.organization_district_id, fac.user_account_id ORDER BY fac.score_datetime DESC) AS last_order
            FROM content_delivery_usage.dbo.fact_assignment_completion fac
            JOIN content_delivery_usage.dbo.organization dis ON fac.organization_district_id = dis.organization_id
            JOIN content_delivery_usage.dbo.learning_assessment_set las ON fac.learning_object_id = las.learning_object_posttest_id --POSTTEST
            JOIN content_delivery_usage.dbo.learning_object lo ON fac.learning_object_id = lo.learning_object_id
            WHERE
                fac.score_datetime >= v_start_date AND fac.score_datetime < v_end_date
                AND dis.is_demo = FALSE
                AND las.assessment_type = v_assessment_type
        ) eh
    WHERE
        eh.last_order = 1;
        

    -- Items & their corresponding DLS standard
    DROP TABLE IF EXISTS _item_alignment;
    CREATE TEMP TABLE _item_alignment
    (
      standard_topic_label  varchar(50)
    , learning_object_id    varchar(50)
    );

    INSERT INTO _item_alignment
    SELECT DISTINCT
        CASE WHEN split_part(parent_st.standard_topic_label, '.', 1) <> 'DLS'
             THEN 'DLS.' || RTRIM(parent_st.standard_topic_label, '.')
             ELSE parent_st.standard_topic_label
        END AS standard_topic_label,
        lo.learning_object_id
    FROM content_delivery_usage.dbo.learning_object lo
    JOIN content_delivery_usage.dbo.learning_object_standard los ON lo.learning_object_id = los.learning_object_id
    JOIN content_delivery_usage.dbo.standard st ON los.standard_topic_id = st.standard_topic_id
    JOIN content_delivery_usage.dbo.standard parent_st ON st.parent_topic_id = parent_st.standard_topic_id
    WHERE lo.learning_object_name NOT ILIKE '%skills check%' --items that are not skills check
        AND parent_st.standard_abbreviation IN ('2019DLSO', 'LCOMDLS')
    ORDER BY
        standard_topic_label,
        learning_object_id;


    DROP TABLE IF EXISTS _curriculum_activity_standard;
    CREATE TEMP TABLE _curriculum_activity_standard
    (
      organization_district_id  varchar(255)
    , user_account_id           varchar(255)
    , assessment_set_id         int
    , standard_topic_label      varchar(50)
    , unique_items              int
    );

    INSERT INTO _curriculum_activity_standard
    SELECT
        sco.organization_district_id,
        sco.user_account_id,
        pre.assessment_set_id,
        pre.standard_topic_label,
        count(distinct sco.learning_object_id) AS unique_items
    FROM
        content_delivery_usage.dbo.fact_assignment_completion sco
        JOIN _first_pre pre ON pre.organization_district_id = sco.organization_district_id AND pre.user_account_id = sco.user_account_id 
        JOIN _item_alignment ia ON sco.learning_object_id = ia.learning_object_id AND pre.standard_topic_label = ia.standard_topic_label
        LEFT JOIN _last_post post ON post.organization_district_id = pre.organization_district_id AND post.user_account_id = pre.user_account_id AND pre.assessment_set_id = post.assessment_set_id
    WHERE
        sco.score_datetime BETWEEN pre.score_datetime AND nvl(post.score_datetime, '1900-01-01')
        OR 
        (sco.score_datetime > pre.score_datetime AND post.score_datetime IS NULL)
    GROUP BY
        sco.organization_district_id,
        sco.user_account_id,
        pre.assessment_set_id,
        pre.standard_topic_label;


    DROP TABLE IF EXISTS _curriculum_activity_before;
    CREATE TEMP TABLE _curriculum_activity_before
    (
      organization_district_id   varchar(255)
    , user_account_id            varchar(255)
    , assessment_set_id          int
    , standard_topic_label       varchar(50)
    , unique_items               int
    );

    INSERT INTO _curriculum_activity_before
    SELECT
        sco.organization_district_id,
        sco.user_account_id,
        pre.assessment_set_id,
        pre.standard_topic_label,
        count(distinct sco.learning_object_id) AS unique_items
    FROM
        content_delivery_usage.dbo.fact_assignment_completion sco
        JOIN _first_pre pre ON sco.organization_district_id = pre.organization_district_id AND sco.user_account_id = pre.user_account_id
        JOIN _item_alignment ia ON sco.learning_object_id = ia.learning_object_id AND pre.standard_topic_label = ia.standard_topic_label
    WHERE
        sco.score_datetime < pre.score_datetime
    GROUP BY
        sco.organization_district_id,
        sco.user_account_id,
        pre.assessment_set_id,
        pre.standard_topic_label;

TRUNCATE TABLE {{target.database}}.{{target.schema}}.stg_skillscheck_schoolyear_data;

INSERT INTO {{target.database}}.{{target.schema}}.stg_skillscheck_schoolyear_data
SELECT cal.schoolyear
     , result.country_code
     , result.state_province_key
     , result.organization_district_id
     , result.organization_school_id
     , result.user_account_id
     , result.user_grade_level_code
     , result.assessment_set_id
     , result.level
     , m.topic_name as skill
     , result.took_both
     , result.pre_learning_object_id
     , result.pre_score_datetime
     , result.pre_time_spent_seconds
     , result.pre_time_spent_seconds_capped
     , result.pre_score
     , result.pre_possible_score
     , result.pre_pct_score AS pre_pct_score
     , result.pre_performance_bucket
     , result.post_learning_object_id
     , result.post_score_datetime
     , result.post_time_spent_seconds
     , result.post_time_spent_seconds_capped
     , result.post_score
     , result.post_possible_score
     , result.post_pct_score AS post_pct_score
     , result.post_performance_bucket
     , result.score_change AS score_change
     , cast(result.score_change / NULLIF(result.pre_possible_score, 0) AS numeric(8,6)) AS pct_score_change
     , cast(result.score_change / NULLIF(result.pre_score, 0) AS numeric(8,6)) AS pct_growth
     , result.unique_items_completed_before
     , result.unique_items_completed_between
FROM {{ ref('skillscheck_topic_mapping') }} m 
JOIN (
    SELECT
        org.country_code,
        org.state_province_key,
        org.organization_id AS organization_district_id,
        sch.organization_id AS organization_school_id,
        COALESCE(pre.user_account_id, post.user_account_id) AS user_account_id,
        COALESCE(post.user_grade_level_code, pre.user_grade_level_code) AS user_grade_level_code, --precedence to grade level at time of posttest
        COALESCE(pre.level, post.level) AS level,
        CASE WHEN pre.score IS NOT NULL AND post.score IS NOT NULL THEN 1 ELSE 0 END AS took_both,
        COALESCE(pre.assessment_set_id, post.assessment_set_id) AS assessment_set_id,
        replace(
            CASE
                WHEN charindex(' Skills Check ', replace(COALESCE(pre.assessment_set_name, post.assessment_set_name), 'Skills Test', 'Skills Check')) > 0 THEN
                    left(
                        replace(COALESCE(pre.assessment_set_name, post.assessment_set_name), 'Skills Test', 'Skills Check'),
                        charindex(' Skills Check ', replace(COALESCE(pre.assessment_set_name, post.assessment_set_name), 'Skills Test', 'Skills Check')) - 1
                    )
                ELSE replace(COALESCE(pre.assessment_set_name, post.assessment_set_name), 'Skills Test', 'Skills Check')
            END,
            ':', ''
        ) AS skill,
        -- Pre test fields
        pre.learning_object_id AS pre_learning_object_id,
        pre.score_datetime AS pre_score_datetime,
        pre.time_spent_seconds AS pre_time_spent_seconds,
        pre.time_spent_seconds_capped AS pre_time_spent_seconds_capped,
        pre.score AS pre_score,
        pre.possible_score AS pre_possible_score,
        cast(pre.score/pre.possible_score as numeric(8,6)) AS pre_pct_score,
        ISNULL(pre.performance_bucket, 'NA') AS pre_performance_bucket,
        -- Post test fields
        post.learning_object_id AS post_learning_object_id,
        post.score_datetime AS post_score_datetime,
        post.time_spent_seconds AS post_time_spent_seconds,
        post.time_spent_seconds_capped AS post_time_spent_seconds_capped,
        post.score AS post_score,
        post.possible_score AS post_possible_score,
        cast(post.score/post.possible_score as numeric(8,6)) AS post_pct_score,
        ISNULL(post.performance_bucket, 'NA') AS post_performance_bucket,
        -- Change and growth calculations
        post.score - pre.score AS score_change,
        cab.unique_items AS unique_items_completed_before,
        cas.unique_items AS unique_items_completed_between
    FROM
        _first_pre pre
        FULL OUTER JOIN _last_post post ON pre.organization_district_id = post.organization_district_id AND pre.user_account_id = post.user_account_id AND pre.assessment_set_id = post.assessment_set_id
        LEFT JOIN content_delivery_usage.dbo.organization org ON org.organization_id = COALESCE(pre.organization_district_id, post.organization_district_id)
        LEFT JOIN _curriculum_activity_before cab ON cab.organization_district_id = COALESCE(pre.organization_district_id, post.organization_district_id) AND cab.user_account_id = COALESCE(pre.user_account_id, post.user_account_id) AND cab.assessment_set_id = COALESCE(pre.assessment_set_id, post.assessment_set_id)
        LEFT JOIN _curriculum_activity_standard cas ON cas.organization_district_id = COALESCE(pre.organization_district_id, post.organization_district_id) AND cas.user_account_id = COALESCE(pre.user_account_id, post.user_account_id) AND cas.assessment_set_id = COALESCE(pre.assessment_set_id, post.assessment_set_id)
        LEFT JOIN content_delivery_usage.dbo.organization sch ON sch.organization_id = COALESCE(pre.organization_school_id, post.organization_school_id)
) AS result ON m.assessment_set_name_partial = result.skill AND m.level = result.level
JOIN {{ ref("dim_calendar") }} cal ON cal.cal_date = v_start_date;

END;

$$
;

{% endset %}

{% do run_query(create_sp_operation) %}

{% endmacro %} 