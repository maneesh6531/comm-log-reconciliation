SELECT
    (
        SELECT COUNT(DISTINCT customer_id)
        FROM communication_log
        WHERE communication_id IN (9001, 9002, 9003)
    )
    +
    (
        SELECT COUNT(*)
        FROM communication_log
        WHERE communication_id = 9101
    )
    +
    (
        SELECT COUNT(DISTINCT customer_id)
        FROM communication_log
        WHERE communication_id IN (9201, 9202)
    ) AS target_base;