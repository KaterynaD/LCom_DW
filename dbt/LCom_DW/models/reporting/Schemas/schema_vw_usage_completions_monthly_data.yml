version: 2

models:
  - name: vw_usage_completions_monthly_data
    description: >
      View combining student usage and completions monthly YTD metrics at
      school–grade level–topic for product_category = '(All)'.
      Built as a left join of fact_students_usage_monthly_snapshots
      (students and launches) with fact_students_completions_monthly_snapshots
      (completions and CIPA-related completion metrics) on mon_year,
      organization_school_id, grade_level, and topic.

    config:
      tags:
        - rep

    columns:
      - name: mon_year
        description: "Calendar Year and Month in a form YYYYMM."

      - name: mon_lastday
        description: "Calendar Month Last day."

      - name: schoolyear
        description: "Calendar years in School Year like 2024/2025."

      - name: schoolyear_mon
        description: "School Year Month number starting from July - 1, ending June - 12."

      - name: country
        description: "Defines Country level for *_country_cnt_* metrics, including students, launches, and completions."

      - name: state_province_code
        description: "Defines State level for *_state_cnt_* metrics along with Country."

      - name: organization_district_id
        description: "Defines District level for *_district_cnt_* metrics along with Country and State."

      - name: organization_school_id
        description: "The lowest level in this view: School, for *_school_cnt_* metrics (students, launches, and completions)."

      - name: grade_level
        description: >
          Grade-level grouping (Elementary–Middle–High).
          Unknown is only for students with unknown grade; non-students are excluded.

      - name: topic
        description: "Learning topic grouping; includes all available topics and '(All)'."


      - name: school_cnt_students
        description: "Unique Count of Students launched an assignment at least once per school year."

      - name: school_students_launches
        description: "Unique Count of assignments launches from students per school year."

      - name: district_cnt_students
        description: "Unique Count of Students launched an assignment at least once per district; repeated for each School."

      - name: district_students_launches
        description: "Unique Count of assignments launches from students per district; repeated for each School."

      - name: state_cnt_students
        description: "Unique Count of Students launched an assignment at least once per state; repeated for each School and District."

      - name: state_students_launches
        description: "Unique Count of assignments launches from students per state; repeated for each School and District."

      - name: country_cnt_students
        description: "Unique Count of Students launched an assignment at least once per country; repeated for each State, School, and District."

      - name: country_students_launches
        description: "Unique Count of assignments launches from students per country; repeated for each State, School, and District."

      - name: company_cnt_students
        description: "Total Unique Count of Students launched an assignment at least once; repeated for each Country, State, School, and District."

      - name: company_students_launches
        description: "Total Unique Count of assignments launches from students; repeated for each Country, State, School, and District."


      - name: school_cnt_completions
        description: "Number of completion records (attempts, scored or not) at school level."

      - name: school_cnt_events
        description: >
          Number of completion events at school level. Event = combination of attempts by
          the same student for the same learning object; may span school years in rare cases.

      - name: school_cnt_student_completions
        description: "Number of distinct students with a completion (attempt, scored or not) at school level."

      - name: school_cnt_student_completions_cipa_digital_citizenship
        description: "Number of students meeting the CIPA digital-citizenship requirement via completions at school level."

      - name: school_cnt_student_completions_cipa_cyberbullying
        description: "Number of students meeting the CIPA cyberbullying requirement at school level."

      - name: school_cnt_student_completionsmeets_both_cipa
        description: "Number of students meeting both CIPA flags at school level."

      - name: district_cnt_completions
        description: "Number of completion records (attempts, scored or not) at district level."

      - name: district_cnt_events
        description: >
          Number of completion events at district level. Event = combination of attempts by
          the same student for the same learning object; may span district school years in rare cases.

      - name: district_cnt_student_completions
        description: "Number of distinct students with a completion (attempt, scored or not) at district level."

      - name: district_cnt_student_completions_cipa_digital_citizenship
        description: "Number of students meeting the CIPA digital-citizenship requirement via completions at district level."

      - name: district_cnt_student_completions_cipa_cyberbullying
        description: "Number of students meeting the CIPA cyberbullying requirement at district level."

      - name: district_cnt_student_completionsmeets_both_cipa
        description: "Number of students meeting both CIPA flags at district level."

      - name: state_cnt_completions
        description: "Number of completion records (attempts, scored or not) at state level."

      - name: state_cnt_events
        description: >
          Number of completion events at state level. Event = combination of attempts by
          the same student for the same learning object; may span state school years in rare cases.

      - name: state_cnt_student_completions
        description: "Number of distinct students with a completion (attempt, scored or not) at state level."

      - name: state_cnt_student_completions_cipa_digital_citizenship
        description: "Number of students meeting the CIPA digital-citizenship requirement via completions at state level."

      - name: state_cnt_student_completions_cipa_cyberbullying
        description: "Number of students meeting the CIPA cyberbullying requirement at state level."

      - name: state_cnt_student_completionsmeets_both_cipa
        description: "Number of students meeting both CIPA flags at state level."

      - name: country_cnt_completions
        description: "Number of completion records (attempts, scored or not) at country level."

      - name: country_cnt_events
        description: >
          Number of completion events at country level. Event = combination of attempts by
          the same student for the same learning object; may span country school years in rare cases.

      - name: country_cnt_student_completions
        description: "Number of distinct students with a completion (attempt, scored or not) at country level."

      - name: country_cnt_student_completions_cipa_digital_citizenship
        description: "Number of students meeting the CIPA digital-citizenship requirement via completions at country level."

      - name: country_cnt_student_completions_cipa_cyberbullying
        description: "Number of students meeting the CIPA cyberbullying requirement at country level."

      - name: country_cnt_student_completionsmeets_both_cipa
        description: "Number of students meeting both CIPA flags at country level."

      - name: company_cnt_completions
        description: "Number of completion records (attempts, scored or not) at company level."

      - name: company_cnt_events
        description: >
          Number of completion events at company level. Event = combination of attempts by
          the same student for the same learning object; may span years in rare cases.

      - name: company_cnt_student_completions
        description: "Number of distinct students with a completion (attempt, scored or not) at company level."

      - name: company_cnt_student_completions_cipa_digital_citizenship
        description: "Number of students meeting the CIPA digital-citizenship requirement via completions at company level."

      - name: company_cnt_student_completions_cipa_cyberbullying
        description: "Number of students meeting the CIPA cyberbullying requirement at company level."

      - name: company_cnt_student_completionsmeets_both_cipa
        description: "Number of students meeting both CIPA flags at company level."
