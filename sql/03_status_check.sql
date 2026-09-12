SELECT
    c.creation_status,
    COUNT(cl.id) AS send_attempts
FROM communication_log cl
JOIN campaign c
    ON cl.communication_id = c.id
WHERE c.merchant_id = 501
  AND c.name LIKE '%Diwali%'
GROUP BY c.creation_status;