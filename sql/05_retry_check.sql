-- Retry family 1
SELECT
    COUNT(*) AS attempts,
    COUNT(DISTINCT cl.customer_id) AS distinct_customers
FROM communication_log cl
JOIN campaign c
    ON cl.communication_id = c.id
WHERE c.id IN (9001, 9002, 9003)
  AND c.creation_status IN ('approved', 'aborted', 'resumed', 'stopped')
  AND c.processing_status = 'processed';


-- Retry family 2
SELECT
    COUNT(*) AS attempts,
    COUNT(DISTINCT cl.customer_id) AS distinct_customers
FROM communication_log cl
JOIN campaign c
    ON cl.communication_id = c.id
WHERE c.id IN (9201, 9202)
  AND c.creation_status IN ('approved', 'aborted', 'resumed', 'stopped')
  AND c.processing_status = 'processed';