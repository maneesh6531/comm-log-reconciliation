SELECT
    c.id,
    c.parent_id,
    c.name,
    c.creation_status,
    c.processing_status,
    COUNT(cl.id) AS send_attempts
FROM communication_log cl
JOIN campaign c
    ON cl.communication_id = c.id
WHERE c.merchant_id = 501
  AND c.name LIKE '%Diwali%'
  AND cl.sent_time >= '2026-10-01 00:00:00'
  AND cl.sent_time < '2026-11-01 00:00:00'
GROUP BY
    c.id,
    c.parent_id,
    c.name,
    c.creation_status,
    c.processing_status
ORDER BY c.id;