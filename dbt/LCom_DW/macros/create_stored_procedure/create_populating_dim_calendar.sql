{% macro create_populating_dim_calendar() %}
 {% set create_sp_operation %}

CREATE OR REPLACE FUNCTION {{target.database}}.common.f_USFederalHolidayCalendar(dt DATE)
RETURNS bool STABLE AS 
$$
from pandas.tseries.holiday import USFederalHolidayCalendar
holidays = USFederalHolidayCalendar().holidays(start='1990-01-01', end='2050-12-31')
return dt in holidays
$$ 
LANGUAGE plpythonu;


CREATE OR REPLACE PROCEDURE {{target.database}}.common.populating_dim_calendar(pstart_date date, pend_date date)
LANGUAGE plpgsql
AS $$
declare
 cal_date_var date;
begin

/**************************************************************************************************
* Name:         populating_dim_calendar
* Description:  Populates dim_calendar with date and business attributes
* Author:       kdrogaieva
* Date Created: 2025MAR26
*
*
* Notes: It should be run just once
* I'd rather have a tables with dates loaded via a csv file in s3, but right now I do not have access
*       
**************************************************************************************************/

/*delete the date range we are going to insert*/
delete from common.dim_calendar where cal_date between pstart_date and pend_date;

drop table if exists stg_calendar;
create temporary table stg_calendar
(cal_date date);

cal_date_var = pstart_date;

LOOP
	
    RAISE INFO 'processing... %', cal_date_var;

	insert into stg_calendar(cal_date) values (cal_date_var);

    cal_date_var = DATEADD(day, 1, cal_date_var);

    EXIT WHEN (cal_date_var > pend_date);

 END LOOP;



insert into common.dim_calendar
SELECT
    cal_date,
    TO_NUMBER(TO_CHAR(cal_date, 'YYYYMMDD'), '99999999')::INTEGER AS Date_Int,
    CASE 
    WHEN DATE_PART(dow, cal_date) = 0 THEN 7  -- Convert Sunday (0) to 7
    ELSE DATE_PART(dow, cal_date) 
    END AS Day_Of_Week, 
    TO_CHAR(cal_date, 'Dy') AS Day_Of_Week_Name_Short,
    TRIM(TO_CHAR(cal_date, 'Day')) AS Day_Of_Week_Name,
    DATE_PART(week, cal_date)::INTEGER AS Week_In_Year,
    DATE_PART(day, cal_date)::INTEGER AS Day_Of_month,
    DATE_PART(month, cal_date)::INTEGER AS Mon,
    TO_CHAR(cal_date, 'Mon') AS Mon_Name_Short,
    TRIM(TO_CHAR(cal_date, 'Month')) AS Mon_Name,
    (DATE_PART(year, cal_date)::VARCHAR+case when DATE_PART(month, cal_date)<10 then '0' else '' end + DATE_PART(month, cal_date)::VARCHAR)::INTEGER AS Mon_Year,
    ((DATE_PART(month, cal_date)::INTEGER - 1) / 3 + 1)::INTEGER AS Quarter,
    (DATE_PART(year, cal_date)::VARCHAR+'0'+Quarter::VARCHAR)::INTEGER AS Quarter_Year,
    DATE_PART(year, cal_date)::INTEGER AS Year,
    DATE_TRUNC('week', cal_date)::DATE AS Mon_WeekStart,
    (DATE_TRUNC('week', cal_date) + INTERVAL '6 days')::DATE AS Sun_WeekEnd,
    DATE_TRUNC('month', cal_date)::DATE AS Mon_FirstDay,
    LAST_DAY(cal_date) AS Mon_LastDay,  -- Use LAST_DAY function for the last day of the month
    CASE 
        WHEN DATE_PART(month, cal_date) < 8 
        THEN (DATE_PART(year, cal_date) - 1)::VARCHAR || '/' || DATE_PART(year, cal_date)::VARCHAR
        ELSE DATE_PART(year, cal_date)::VARCHAR || '/' || (DATE_PART(year, cal_date) + 1)::VARCHAR
    END AS SchoolYear,
    CASE 
        WHEN DATE_PART(month, cal_date) < 8 
        THEN TO_DATE((DATE_PART(year, cal_date) - 1)::VARCHAR || '-08-01', 'YYYY-MM-DD')
        ELSE TO_DATE(DATE_PART(year, cal_date)::VARCHAR || '-08-01', 'YYYY-MM-DD')
    END AS SchoolYear_StartDate,
    CASE 
        WHEN DATE_PART(month, cal_date) < 8 
        THEN TO_DATE(DATE_PART(year, cal_date)::VARCHAR || '-07-31', 'YYYY-MM-DD')
        ELSE TO_DATE((DATE_PART(year, cal_date) + 1)::VARCHAR || '-07-31', 'YYYY-MM-DD')
    END AS SchoolYear_EndDate,
    CASE 
        WHEN Mon >= 8 THEN Mon - 7  -- August (8) to December (12) → 1 to 5
        ELSE Mon + 5                -- January (1) to July (7) → 6 to 12
    END SchoolYear_Mon,
    CASE 
        WHEN DATE_PART(month, cal_date) < 8 
        THEN (DATE_PART(year, cal_date) - 1)::VARCHAR || '/' || DATE_PART(year, cal_date)::VARCHAR
        ELSE DATE_PART(year, cal_date)::VARCHAR || '/' || (DATE_PART(year, cal_date) + 1)::VARCHAR
    END AS FiscalYear,
    CASE 
        WHEN DATE_PART(month, cal_date) < 8 
        THEN TO_DATE((DATE_PART(year, cal_date) - 1)::VARCHAR || '-08-01', 'YYYY-MM-DD')
        ELSE TO_DATE(DATE_PART(year, cal_date)::VARCHAR || '-08-01', 'YYYY-MM-DD')
    END AS FiscalYear_StartDate,
    CASE 
        WHEN DATE_PART(month, cal_date) < 8 
        THEN TO_DATE(DATE_PART(year, cal_date)::VARCHAR || '-07-31', 'YYYY-MM-DD')
        ELSE TO_DATE((DATE_PART(year, cal_date) + 1)::VARCHAR || '-07-31', 'YYYY-MM-DD')
    END AS FiscalYear_EndDate,
    (((DATE_PART(month, cal_date)::INTEGER - 8 + 12) % 12) / 3 + 1)::INTEGER AS FiscalQuarter,
    (DATE_PART(year, cal_date)::VARCHAR +'0'+ FiscalQuarter::VARCHAR)::INTEGER  AS FiscalQuarter_Year
    ,common.f_USFederalHolidayCalendar(cal_date) AS IsUSFederalHoliday  -- Using the Python UDF
FROM  stg_calendar;

drop table if exists stg_calendar;

END;

$$
;
{% endset %}

{% do run_query(create_sp_operation) %}

{% endmacro %} 