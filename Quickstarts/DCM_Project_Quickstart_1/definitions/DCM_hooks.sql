attach pre_hook
as [    
    -- requires role privilege to create integration on account
    create API INTEGRATION if not exists GITHUB_API{{env_suffix}}
        API_PROVIDER = git_https_api
        API_ALLOWED_PREFIXES = ('https://github.com')
        ALLOWED_AUTHENTICATION_SECRETS = all
        ENABLED = true;

    -- requires role privilege to create integration on account
    create NOTIFICATION INTEGRATION if not exists DCM_EMAIL_NOTIFICATIONS{{env_suffix}}
        TYPE = EMAIL
        ENABLED = true
        ALLOWED_RECIPIENTS = ('jan.sommerfeld@snowflake.com');

    -- requires role privilege to create share on account
    create SHARE if not exists DCM_DEMO_SHARE{{env_suffix}}
        comment = 'created in prehook so DCM can add grants to share';
];



attach post_hook
as [
    
    create SEMANTIC VIEW if not exists DCM_DEMO_1{{env_suffix}}.SERVE.MENU_SEMANTIC_VIEW
      TABLES (
        menu as DCM_DEMO_1{{env_suffix}}.RAW.MENU
      )
      DIMENSIONS (
        menu.menu_item_id as MENU_ITEM_ID
          comment = 'Unique identifier for menu item',
        menu.menu_item_name as MENU_ITEM_NAME
          comment = 'Name of the menu item',
        menu.item_category as ITEM_CATEGORY
          comment = 'Category of the menu item'
      )
      METRICS (
        menu.cost_of_goods_usd as AVG(COST_OF_GOODS_USD)
          comment = 'Average cost of menu items',
        menu.sale_price_usdsd as AVG(SALE_PRICE_USD)
          comment = 'Average sale price of menu items'
      )
      comment = 'Demo semantic view for menu analytics'
      ;
    
    create ALERT if not exists DCM_DEMO_1{{env_suffix}}.SERVE.DCM_ALERT
        warehouse = 'DCM_WH'
        schedule = 'USING CRON 0 9 * * * UTC'
        if (exists (
            select 1 
            from 
                DCM_DEMO_1{{env_suffix}}.RAW.INVENTORY
            where 
                IN_STOCK < 10 
                and COUNTED_ON >= CURRENT_DATE() - 1
        ))
        then
            call SYSTEM$SEND_EMAIL(
                'dcm_demo_notification',
                'jan.sommerfeld@snowflake.com',
                'DCM Alert: Low Inventory Detected',
                'One or more items have inventory below threshold. Please review the INVENTORY table.'
            );

    create STREAM if not exists DCM_DEMO_1{{env_suffix}}.RAW.NEW_INVENTORY
    on table DCM_DEMO_1{{env_suffix}}.RAW.INVENTORY
        append_only = TRUE
    ;
    
    create or replace FILE FORMAT DCM_DEMO_1{{env_suffix}}.RAW.DCM_DEMO_CSV
      TYPE = CSV
      FIELD_DELIMITER = '|'
      SKIP_HEADER = 1
      NULL_IF = ('NULL', 'null')
      EMPTY_FIELD_AS_NULL = true
      COMPRESSION = gzip;
];
