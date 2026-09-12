SELECT
    c.id AS campaign_id,
    c.parent_id,
    c.name,
    COUNT(*) AS attempts,
    COUNT(DISTINCT cl.customer_id) AS distinct_customers
FROM communication_log cl
JOIN campaign c
    ON cl.communication_id = c.id
WHERE c.id = 9101
GROUP BY
    c.id,
    c.parent_id,
    c.name;