{{ config(
    severity='error',
    tags=['source_test']
) }}

SELECT booking_id, booking_amount
FROM {{ source('staging', 'bookings') }}
WHERE booking_amount <= 0
   OR booking_amount IS NULL