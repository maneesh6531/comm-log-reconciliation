SELECT COUNT(*) AS naive_count
FROM communication_log cl
JOIN campaign c
    ON cl.communication_id = c.id
WHERE c.merchant_id = 501
  AND c.name LIKE '%Diwali%'
  AND cl.sent_time >= '2026-10-01 00:00:00'
  AND cl.sent_time < '2026-11-01 00:00:00';