{{ config(
    severity='warn',
    tags=['source_test']
) }}

SELECT
    1
FROM
    {{ source('staging', 'bookings')}}
WHERE
    booking_amount < 100