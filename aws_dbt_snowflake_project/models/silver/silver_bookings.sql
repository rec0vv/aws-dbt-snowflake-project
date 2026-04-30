{{
  config(materialized = 'incremental', unique_key = 'booking_id')
}}

SELECT 
    BOOKING_ID,
    LISTING_ID,
    BOOKING_DATE,
    {{multiply('Nights_booked' ,'Booking_amount',2)}} AS TOTAL_AMOUNT, 
    CLEANING_FEE,
    SERVICE_FEE,
    BOOKING_STATUS,
    CREATED_AT

    FROM {{ ref('bronze_bookings')}}