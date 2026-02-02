-- first set: data_metric_schedule = 'TRIGGER_ON_CHANGES'

attach data metric function SNOWFLAKE.CORE.NULL_COUNT
    to table DCM_DEMO_2.RAW.PROSPECT_STG
    on (AGENCYID)
    expectation NO_MISSING_ID (value = 0);


attach data metric function SNOWFLAKE.CORE.MAX
    to table DCM_DEMO_2.RAW.PROSPECT_STG
    on (AGE)
    expectation NO_DEAD_PROSPECTS (value < 120);


attach data metric function SNOWFLAKE.CORE.MIN
    to table DCM_DEMO_2.RAW.PROSPECT_STG
    on (AGE)
    expectation NO_KIDS (value > 18);