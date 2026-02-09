-- Transformations SQL
-- Purpose: Clean, validate, and enrich raw transaction data
-- Input: raw_transactions (temporary view)
-- Output: Transformed and enriched transaction records

SELECT 
    -- Primary identifiers
    transaction_id,
    user_id,
    product_id,
    product_category,
    
    -- Transaction amounts
    amount,
    quantity,
    COALESCE(discount_percent, 0.0) AS discount_percent,
    
    -- Calculate discounted amount
    ROUND(amount * (1 - COALESCE(discount_percent, 0.0) / 100.0), 2) AS discounted_amount,
    
    -- Calculate revenue (discounted amount * quantity)
    ROUND(amount * quantity * (1 - COALESCE(discount_percent, 0.0) / 100.0), 2) AS revenue,
    
    -- Payment and status information
    payment_method,
    status,
    CASE 
        WHEN status = 'completed' THEN 'success'
        WHEN status = 'pending' THEN 'in_progress'
        WHEN status IN ('failed', 'refunded') THEN 'unsuccessful'
        ELSE 'unknown'
    END AS status_category,
    
    -- Customer information
    COALESCE(customer_segment, 'unclassified') AS customer_segment,
    country_code,
    
    -- Timestamp parsing and date extraction
    CAST(event_time AS TIMESTAMP) AS event_timestamp,
    TO_DATE(CAST(event_time AS TIMESTAMP)) AS event_date,
    HOUR(CAST(event_time AS TIMESTAMP)) AS event_hour,
    DAYOFWEEK(CAST(event_time AS TIMESTAMP)) AS day_of_week,
    
    -- Derived flags and indicators
    CASE 
        WHEN amount >= 200.0 THEN true
        ELSE false
    END AS is_high_value,
    
    CASE 
        WHEN quantity > 3 THEN true
        ELSE false
    END AS is_bulk_order,
    
    CASE 
        WHEN COALESCE(discount_percent, 0.0) > 0 THEN true
        ELSE false
    END AS has_discount,
    
    -- Current processing timestamp
    CURRENT_TIMESTAMP() AS processed_timestamp

FROM raw_transactions

-- Data quality filters
WHERE 
    transaction_id IS NOT NULL
    AND user_id IS NOT NULL
    AND product_id IS NOT NULL
    AND amount > 0
    AND quantity > 0
    AND status IS NOT NULL
    AND event_time IS NOT NULL
