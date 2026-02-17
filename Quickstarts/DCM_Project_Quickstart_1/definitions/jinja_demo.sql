-- loop through lists
{% for team in teams %}
    {% set team = team | upper %}

    define schema DCM_DEMO_1{{env_suffix}}.{{team}}
        comment = 'using JINJA FILTER for upper';

    -- Run the macro to create all roles and grants for this schema
    {{ create_team_roles(team) }}
        
    define table DCM_DEMO_1{{env_suffix}}.{{team}}.PRODUCTS(
        ITEM_NAME varchar,
        ITEM_ID varchar,
        ITEM_CATEGORY array
    )
    data_metric_schedule = 'TRIGGER_ON_CHANGES'
    ;

    attach data metric function SNOWFLAKE.CORE.NULL_COUNT
        to table DCM_DEMO_1{{env_suffix}}.{{team}}.PRODUCTS
        on (ITEM_ID)
        expectation NO_MISSING_ID (value = 0);
        
    -- define conditions 
    {% if team == 'HR' %}
        define table DCM_DEMO_1{{env_suffix}}.{{team}}.EMPLOYEES(
            NAME varchar,
            ID int
        )
        comment = 'This table is only created in HR'
        ;
    {% endif %}

{% endfor %}


-- ### check the jinja_demo file in the PLAN output to see the rendered jinja 