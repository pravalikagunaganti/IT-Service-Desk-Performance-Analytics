USE service_desk_analytics;

-- ============================================================
-- 1. BASELINE SERVICE DESK KPIs
-- ============================================================

SELECT
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN first_response_at IS NOT NULL THEN 1 ELSE 0 END)
        AS responded_tickets,
    SUM(CASE WHEN closed_at IS NOT NULL THEN 1 ELSE 0 END)
        AS resolved_tickets,
    SUM(COALESCE(response_breached, 0)) AS response_breaches,
    SUM(COALESCE(resolution_breached, 0)) AS resolution_breaches,
    SUM(COALESCE(is_reopened, 0)) AS reopened_tickets,
    ROUND(AVG(ttfr_hours), 2) AS avg_response_hours,
    ROUND(AVG(resolution_hours), 2) AS avg_resolution_hours,
    ROUND(AVG(csat_score), 2) AS avg_csat
FROM tickets;


-- ============================================================
-- 2. PERFORMANCE BY CATEGORY
-- ============================================================

SELECT
    category,
    COUNT(*) AS total_tickets,
    SUM(COALESCE(response_breached, 0)) AS response_breaches,
    SUM(COALESCE(resolution_breached, 0)) AS resolution_breaches,
    ROUND(
        100.0 * SUM(COALESCE(resolution_breached, 0))
        / NULLIF(COUNT(resolution_hours), 0),
        1
    ) AS resolution_breach_rate_pct,
    ROUND(AVG(ttfr_hours), 2) AS avg_response_hours,
    ROUND(AVG(resolution_hours), 2) AS avg_resolution_hours
FROM tickets
WHERE resolution_hours IS NOT NULL
GROUP BY category
ORDER BY resolution_breach_rate_pct DESC;


-- ============================================================
-- 3. PERFORMANCE BY PRIORITY
-- ============================================================

SELECT
    priority,
    COUNT(*) AS total_tickets,
    SUM(COALESCE(response_breached, 0)) AS response_breaches,
    SUM(COALESCE(resolution_breached, 0)) AS resolution_breaches,
    ROUND(
        100.0 * SUM(COALESCE(resolution_breached, 0))
        / NULLIF(COUNT(resolution_hours), 0),
        1
    ) AS resolution_breach_rate_pct,
    ROUND(AVG(ttfr_hours), 2) AS avg_response_hours,
    ROUND(AVG(resolution_hours), 2) AS avg_resolution_hours
FROM tickets
WHERE resolution_hours IS NOT NULL
GROUP BY priority
ORDER BY resolution_breach_rate_pct DESC;


-- ============================================================
-- 4. CATEGORY × PRIORITY PERFORMANCE
-- ============================================================

SELECT
    category,
    priority,
    COUNT(*) AS total_tickets,
    SUM(COALESCE(resolution_breached, 0)) AS resolution_breaches,
    ROUND(
        100.0 * SUM(COALESCE(resolution_breached, 0))
        / NULLIF(COUNT(resolution_hours), 0),
        1
    ) AS resolution_breach_rate_pct,
    ROUND(AVG(resolution_hours), 2) AS avg_resolution_hours
FROM tickets
WHERE resolution_hours IS NOT NULL
GROUP BY category, priority
ORDER BY resolution_breach_rate_pct DESC, total_tickets DESC;


-- ============================================================
-- 5. CATEGORY MISMATCH ANALYSIS
-- ============================================================

SELECT
    CASE
        WHEN category_mismatch = 1 THEN 'Mismatch'
        WHEN category_mismatch = 0 THEN 'No Mismatch'
        ELSE 'Unknown'
    END AS category_status,
    COUNT(*) AS total_tickets,
    SUM(COALESCE(response_breached, 0)) AS response_breaches,
    SUM(COALESCE(resolution_breached, 0)) AS resolution_breaches,
    ROUND(
        100.0 * SUM(COALESCE(resolution_breached, 0))
        / NULLIF(COUNT(resolution_hours), 0),
        1
    ) AS resolution_breach_rate_pct,
    ROUND(AVG(ttfr_hours), 2) AS avg_response_hours
FROM tickets
WHERE category_mismatch IS NOT NULL
  AND resolution_hours IS NOT NULL
GROUP BY category_status
ORDER BY resolution_breach_rate_pct DESC;


-- ============================================================
-- 6. REOPENED VS NON-REOPENED TICKETS
-- ============================================================

SELECT
    CASE
        WHEN is_reopened = 1 THEN 'Reopened'
        ELSE 'Not Reopened'
    END AS reopen_status,
    COUNT(*) AS total_tickets,
    ROUND(AVG(resolution_hours), 2) AS avg_resolution_hours,
    SUM(COALESCE(resolution_breached, 0)) AS resolution_breaches,
    ROUND(
        100.0 * SUM(COALESCE(resolution_breached, 0))
        / NULLIF(COUNT(resolution_hours), 0),
        1
    ) AS resolution_breach_rate_pct,
    ROUND(AVG(csat_score), 2) AS avg_csat,
    COUNT(csat_score) AS csat_responses
FROM tickets
WHERE resolution_hours IS NOT NULL
GROUP BY reopen_status
ORDER BY resolution_breach_rate_pct DESC;


-- ============================================================
-- 7. RESOLUTION SLA BREACH VS CUSTOMER SATISFACTION
-- ============================================================

SELECT
    CASE
        WHEN resolution_breached = 1 THEN 'Resolution SLA Breached'
        WHEN resolution_breached = 0 THEN 'Resolution SLA Met'
        ELSE 'Unknown'
    END AS sla_status,
    COUNT(csat_score) AS csat_responses,
    ROUND(AVG(csat_score), 2) AS avg_csat
FROM tickets
WHERE csat_score IS NOT NULL
  AND resolution_breached IS NOT NULL
GROUP BY sla_status
ORDER BY avg_csat DESC;


-- ============================================================
-- 8. MONTHLY RESOLUTION SLA TREND
-- ============================================================

SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS ticket_month,
    COUNT(*) AS total_tickets,
    COUNT(resolution_hours) AS tickets_with_resolution,
    SUM(
        CASE
            WHEN resolution_hours IS NOT NULL
             AND resolution_breached = 1
            THEN 1
            ELSE 0
        END
    ) AS resolution_breaches,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN resolution_hours IS NOT NULL
                 AND resolution_breached = 1
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(resolution_hours), 0),
        1
    ) AS resolution_breach_rate_pct,
    ROUND(AVG(resolution_hours), 2) AS avg_resolution_hours
FROM tickets
GROUP BY DATE_FORMAT(created_at, '%Y-%m')
ORDER BY ticket_month;


-- ============================================================
-- 9. RESPONSE SLA PERFORMANCE BY CATEGORY
-- ============================================================

SELECT
    category,
    COUNT(ttfr_hours) AS tickets_with_response,
    SUM(
        CASE
            WHEN ttfr_hours IS NOT NULL
             AND response_breached = 1
            THEN 1
            ELSE 0
        END
    ) AS response_breaches,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN ttfr_hours IS NOT NULL
                 AND response_breached = 1
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(ttfr_hours), 0),
        1
    ) AS response_breach_rate_pct,
    ROUND(AVG(ttfr_hours), 2) AS avg_response_hours
FROM tickets
WHERE ttfr_hours IS NOT NULL
GROUP BY category
ORDER BY response_breach_rate_pct DESC;


-- ============================================================
-- 10. LEGACY VS NON-LEGACY TICKETS
-- ============================================================

SELECT
    CASE
        WHEN is_legacy = 1 THEN 'Legacy'
        WHEN is_legacy = 0 THEN 'Non-Legacy'
        ELSE 'Unknown'
    END AS ticket_type,
    COUNT(*) AS total_tickets,
    COUNT(resolution_hours) AS tickets_with_resolution,
    SUM(
        CASE
            WHEN resolution_hours IS NOT NULL
             AND resolution_breached = 1
            THEN 1
            ELSE 0
        END
    ) AS resolution_breaches,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN resolution_hours IS NOT NULL
                 AND resolution_breached = 1
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(resolution_hours), 0),
        1
    ) AS resolution_breach_rate_pct,
    ROUND(AVG(resolution_hours), 2) AS avg_resolution_hours
FROM tickets
GROUP BY ticket_type
ORDER BY resolution_breach_rate_pct DESC;


-- ============================================================
-- 11. INCIDENT VS NON-INCIDENT TICKETS
-- ============================================================

SELECT
    CASE
        WHEN is_incident_ticket = 1 THEN 'Incident'
        WHEN is_incident_ticket = 0 THEN 'Non-Incident'
        ELSE 'Unknown'
    END AS incident_status,
    COUNT(*) AS total_tickets,
    COUNT(resolution_hours) AS tickets_with_resolution,
    SUM(
        CASE
            WHEN resolution_hours IS NOT NULL
             AND resolution_breached = 1
            THEN 1
            ELSE 0
        END
    ) AS resolution_breaches,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN resolution_hours IS NOT NULL
                 AND resolution_breached = 1
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(resolution_hours), 0),
        1
    ) AS resolution_breach_rate_pct,
    ROUND(AVG(resolution_hours), 2) AS avg_resolution_hours,
    ROUND(AVG(csat_score), 2) AS avg_csat
FROM tickets
GROUP BY incident_status
ORDER BY resolution_breach_rate_pct DESC;


-- ============================================================
-- 12. REOPEN CHILD VS NON-CHILD TICKETS
-- ============================================================

SELECT
    CASE
        WHEN is_reopen_child = 1 THEN 'Reopen Child'
        WHEN is_reopen_child = 0 THEN 'Not Reopen Child'
        ELSE 'Unknown'
    END AS reopen_child_status,
    COUNT(*) AS total_tickets,
    COUNT(resolution_hours) AS tickets_with_resolution,
    SUM(
        CASE
            WHEN resolution_hours IS NOT NULL
             AND resolution_breached = 1
            THEN 1
            ELSE 0
        END
    ) AS resolution_breaches,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN resolution_hours IS NOT NULL
                 AND resolution_breached = 1
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(resolution_hours), 0),
        1
    ) AS resolution_breach_rate_pct,
    ROUND(AVG(resolution_hours), 2) AS avg_resolution_hours,
    ROUND(AVG(csat_score), 2) AS avg_csat
FROM tickets
GROUP BY reopen_child_status
ORDER BY resolution_breach_rate_pct DESC;