SET NOCOUNT ON;
SET STATISTICS TIME ON;

DECLARE @EmpSubId INT;

SELECT @EmpSubId = subdivision_id
FROM collaborators
WHERE id = 710253;

;WITH RecursiveTree AS (
    SELECT
        s.id,
        s.name,
        s.parent_id,
        CAST(0 AS INT) AS sub_level,
        CASE 
            WHEN s.id = @EmpSubId THEN 1 
            ELSE 0 
        END AS in_emp_subtree
    FROM subdivisions AS s
    WHERE s.parent_id IS NULL

    UNION ALL

    SELECT
        s.id,
        s.name,
        s.parent_id,
        rt.sub_level + 1 AS sub_level,
        CASE 
            WHEN s.id = @EmpSubId OR rt.in_emp_subtree = 1 THEN 1 
            ELSE 0 
        END AS in_emp_subtree
    FROM subdivisions AS s
    INNER JOIN RecursiveTree AS rt
        ON s.parent_id = rt.id
)

SELECT
    c.id              AS id,
    c.name            AS name,
    rt.name           AS sub_name,
    rt.id             AS sub_id,
    rt.sub_level      AS sub_level,
    COUNT(*) OVER (PARTITION BY c.subdivision_id) AS colls_count
FROM collaborators AS c
INNER JOIN RecursiveTree AS rt
    ON c.subdivision_id = rt.id
WHERE
    rt.in_emp_subtree = 1
    AND c.age < 40
    AND rt.id NOT IN (100055, 100059)
ORDER BY
    rt.sub_level ASC,
    rt.id ASC,
    c.id ASC;

-- SET STATISTICS TIME OFF;
