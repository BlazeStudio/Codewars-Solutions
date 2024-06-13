--https://www.codewars.com/kata/663109d79cda6608c36fb77a

WITH questionable_expenses AS (
    SELECT
        d.department_name,
        SUM(e.amount) AS total_questionable_expenses
    FROM
        expenses e
    JOIN departments d ON e.department_id = d.department_id
    WHERE
        LOWER(description) LIKE '%confetti%' OR
        LOWER(description) LIKE '%glitter%' OR
        LOWER(description) LIKE '%golden toilet%' OR
        LOWER(description) LIKE '%massage chair%' OR
        LOWER(description) LIKE '%video game%' OR
        LOWER(description) LIKE '%karaoke%' OR
        (EXTRACT(MONTH FROM date) = 4 AND EXTRACT(DAY FROM date) = 1) OR
        (EXTRACT(MONTH FROM date) = 5 AND EXTRACT(DAY FROM date) = 21)
    GROUP BY
        d.department_name
)
SELECT
    department_name,
    total_questionable_expenses::money
FROM
    questionable_expenses
ORDER BY
    total_questionable_expenses DESC,
    department_name DESC
LIMIT 5;