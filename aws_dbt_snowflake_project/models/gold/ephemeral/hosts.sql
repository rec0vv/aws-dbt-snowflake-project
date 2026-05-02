{{
    config(
        materialized = 'ephemeral',
    )
}}

WITH hosts AS 
(
    SELECT
        HOST_ID,
        HOST_NAME,
        HOSTING_SINCE,
        IS_SUPERHOST,
        RESPONSE_RATE_QUALITY,
        HOST_CREATED_AT
    FROM
        {{ ref('obt') }}
)
SELECT * FROM hosts