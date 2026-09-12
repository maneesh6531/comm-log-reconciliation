SELECT
    (
        SELECT COUNT(DISTINCT cl.customer_id)
        FROM communication_log cl
        JOIN campaign c
            ON cl.communication_id = c.id
        WHERE c.id IN (9001, 9002, 9003)
          AND c.creation_status IN ('approved', 'aborted', 'resumed', 'stopped')
          AND c.processing_status = 'processed'
    )
    +
    (
        SELECT COUNT(*)
        FROM communication_log cl
        JOIN campaign c
            ON cl.communication_id = c.id
        WHERE c.id = 9101
          AND c.creation_status IN ('approved', 'aborted', 'resumed', 'stopped')
          AND c.processing_status = 'processed'
    )
    +
    (
        SELECT COUNT(DISTINCT cl.customer_id)
        FROM communication_log cl
        JOIN campaign c
            ON cl.communication_id = c.id
        WHERE c.id IN (9201, 9202)
          AND c.creation_status IN ('approved', 'aborted', 'resumed', 'stopped')
          AND c.processing_status = 'processed'
    ) AS target_base;