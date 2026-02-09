-- Aggregations SQL
-- Purpose: Calculate real-time metrics and KPIs from transformed transactions
-- Input: transformed_transactions (temporary view)
-- Output: Aggregated metrics by product category

SELECT 
    product_category,
    
    -- Transaction counts
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT user_id) AS unique_customers,
    COUNT(DISTINCT product_id) AS unique_products,
    
    -- Revenue metrics
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(revenue), 2) AS avg_transaction_value,
    ROUND(MIN(revenue), 2) AS min_transaction_value,
    ROUND(MAX(revenue), 2) AS max_transaction_value,
    
    -- Volume metrics
    SUM(quantity) AS total_quantity_sold,
    ROUND(AVG(quantity), 2) AS avg_quantity_per_transaction,
    
    -- Discount analysis
    ROUND(AVG(discount_percent), 2) AS avg_discount_percent,
    SUM(CASE WHEN has_discount THEN 1 ELSE 0 END) AS discounted_transactions,
    ROUND(SUM(CASE WHEN has_discount THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS discount_rate_percent,
    
    -- High value transactions
    SUM(CASE WHEN is_high_value THEN 1 ELSE 0 END) AS high_value_transactions,
    ROUND(SUM(CASE WHEN is_high_value THEN revenue ELSE 0 END), 2) AS high_value_revenue,
    
    -- Bulk orders
    SUM(CASE WHEN is_bulk_order THEN 1 ELSE 0 END) AS bulk_orders,
    ROUND(SUM(CASE WHEN is_bulk_order THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS bulk_order_rate_percent,
    
    -- Status breakdown
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed_transactions,
    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending_transactions,
    SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) AS failed_transactions,
    SUM(CASE WHEN status = 'refunded' THEN 1 ELSE 0 END) AS refunded_transactions,
    
    -- Completion rate
    ROUND(SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS completion_rate_percent,
    
    -- Customer segment breakdown
    SUM(CASE WHEN customer_segment = 'premium' THEN 1 ELSE 0 END) AS premium_customers,
    SUM(CASE WHEN customer_segment = 'regular' THEN 1 ELSE 0 END) AS regular_customers,
    SUM(CASE WHEN customer_segment = 'new' THEN 1 ELSE 0 END) AS new_customers,
    
    -- Payment method distribution
    SUM(CASE WHEN payment_method = 'credit_card' THEN 1 ELSE 0 END) AS credit_card_payments,
    SUM(CASE WHEN payment_method = 'debit_card' THEN 1 ELSE 0 END) AS debit_card_payments,
    SUM(CASE WHEN payment_method = 'paypal' THEN 1 ELSE 0 END) AS paypal_payments,
    SUM(CASE WHEN payment_method = 'bank_transfer' THEN 1 ELSE 0 END) AS bank_transfer_payments,
    
    -- Timestamp for when aggregation was computed
    CURRENT_TIMESTAMP() AS aggregation_timestamp

FROM transformed_transactions

GROUP BY product_category
