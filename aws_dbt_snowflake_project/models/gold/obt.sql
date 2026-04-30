{% set configs = [
    {
        "table" : "AIRBNB.BRONZE.BRONZE_BOOKINGS",
        "columns": "*",
        "alias": "bronze_bookings"
    },
    {
        "table" : "AIRBNB.BRONZE.BRONZE_LISTINGS",
        "columns": "bronze_listings.host_id, bronze_listings.property_type, bronze_listings.room_type, bronze_listings.city, bronze_listings.country, bronze_listings.accommodates, bronze_listings.bedrooms, bronze_listings.bathrooms, bronze_listings.price_per_night, silver_listings.price_per_night_tag, bronze_listings.created_at as listing_created_at "
        "alias": "bronze_listings",
        "join_condition" : "bronze_bookings.listing_id = bronze_listings.listing_id"
    },
    {
        "table" : "AIRBNB.BRONZE.BRONZE_HOSTS",
        "columns": "bronze_hosts.host_name, bronze_hosts.host_since, bronze_hosts.is_superhost, bronze_hosts.response_rate, bronze_hosts.response_rate_quality, bronze_hosts.created_at as host_created_at"
        "alias": "bronze_hosts",
        "join_condition" : "bronze_listings.host_id = bronze_hosts.host_id"
    }
]   %}