{% for team in teams %}

    define warehouse DCM_DEMO_2_{{team}}_WH{{env_suffix}}
        with warehouse_size='{{wh_size}}'
        comment = 'For DCM Demo Quickstart 2';
        
    define database DCM_DEMO_2_{{team}}{{env_suffix}};
    define schema DCM_DEMO_2_{{team}}{{env_suffix}}.PROJECTS;

    {{ create_team_roles(team) }}
    
    {% if team == 'Finance' %}
        grant USAGE on database DCM_DEMO_2 to role DCM_DEMO_2_{{team}}_ADMIN;
        grant USAGE on schema DCM_DEMO_2.RAW to role DCM_DEMO_2_{{team}}_ADMIN;
        grant select on ALL TABLES in schema DCM_DEMO_2.RAW to role DCM_DEMO_2_{{team}}_ADMIN;    
    {% endif %}
    
{% endfor %}