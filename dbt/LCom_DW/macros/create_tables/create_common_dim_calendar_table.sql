{% macro create_common_dim_calendar_table() %}
 {% set create_table_operation %}

drop table if exists common.dim_calendar;
create table common.dim_calendar
(
Cal_Date date not null,
Date_Int int not null,
Day_Of_Week int not null,
Day_Of_Week_Name_Short varchar(3) not null,
Day_Of_Week_Name varchar(10) not null,
Week_In_Year int not null,
Day_Of_month int not null,
Mon int not null,
Mon_Name_Short varchar(3) not null,
Mon_Name varchar(10) not null,
Mon_Year int not null,
Quarter int not null,
Quarter_Year int not null,
Year int not null not null,
Mon_WeekStart date not null,
Sun_WeekEnd date not null,
Mon_FirstDay date not null,
Mon_LastDay date not null,
SchoolYear varchar(20) not null,
SchoolYear_StartDate date not null,
SchoolYear_EndDate date not null,
SchoolYear_Mon int not null,
FiscalYear varchar(20) not null,
FiscalYear_StartDate date not null,
FiscalYear_EndDate date not null,
FiscalYear_Mon int not null,
FiscalQuarter int not null,
FiscalQuarter_Year int not null,
IsUSFederalHoliday  boolean not null,
PRIMARY KEY (cal_date)
)
DISTSTYLE ALL
;


COMMENT ON TABLE common.dim_calendar IS 'Calendar dates and derived attributes - as school Years start and end dates, fiscal years etc';

{% endset %}

{% do run_query(create_table_operation) %}

{% endmacro %} 