SELECT COUNT(*) AS eligible_count
FROM communication_log cl
JOIN campaign c
    ON cl.communication_id = c.id
WHERE c.merchant_id = 501
  AND c.name LIKE '%Diwali%'
  AND cl.sent_time >= '2026-10-01 00:00:00'
  AND cl.sent_time < '2026-11-01 00:00:00'
  AND c.creation_status IN ('approved', 'aborted', 'resumed', 'stopped')
  AND c.processing_status = 'processed';