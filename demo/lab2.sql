
-- 1. Какие клиенты купили абонементы и сколько они стоят?
-- expect: rows
SELECT
    c.name,
    c.surname,
    m.starts_at,
    m.ends_at,
    m.price
FROM clients c
JOIN memberships m ON m.client_id = c.id
ORDER BY c.surname;


-- 2. На какие занятия записаны клиенты?
-- expect: rows
SELECT
    cl.name AS class_name,
    c.name AS client_name,
    c.surname AS client_surname
FROM classes cl
JOIN registrations r ON r.class_id = cl.id
JOIN clients c ON c.id = r.client_id
ORDER BY cl.name, c.surname;


-- 3. Какие занятия запланированы и кто их проводит?
-- expect: rows
SELECT
    cl.name AS class_name,
    cl.starts_at,
    cl.ends_at,
    cl.capacity,
    t.name AS trainer_name,
    t.surname AS trainer_surname
FROM classes cl
JOIN trainers t ON t.id = cl.trainer_id
ORDER BY cl.starts_at
LIMIT 10;


-- 4. Сколько клиентов записано на каждое занятие?
-- expect: rows
SELECT
    cl.id,
    cl.name AS class_name,
    cl.starts_at,
    COUNT(r.id) AS registrations_count
FROM classes cl
LEFT JOIN registrations r ON r.class_id = cl.id
GROUP BY cl.id, cl.name, cl.starts_at
ORDER BY registrations_count DESC, cl.starts_at;


-- 5. Какие клиенты ни разу не записывались на занятия?
-- expect: rows
SELECT
    c.id,
    c.name,
    c.surname,
    c.phone_number
FROM clients c
LEFT JOIN registrations r ON r.client_id = c.id
WHERE r.id IS NULL
ORDER BY c.surname;


-- 6. Какие тренеры проводят минимум два занятия?
-- expect: rows
SELECT
    t.id,
    t.name,
    t.surname,
    COUNT(cl.id) AS classes_count
FROM trainers t
JOIN classes cl ON cl.trainer_id = t.id
GROUP BY t.id, t.name, t.surname
HAVING COUNT(cl.id) >= 2
ORDER BY classes_count DESC, t.surname;


-- 7. Какие клиенты приобрели абонемент стоимостью не менее 4500 рублей?
-- expect: rows
SELECT
    c.id,
    c.name,
    c.surname
FROM clients c
WHERE c.id IN (
    SELECT m.client_id
    FROM memberships m
    WHERE m.price >= 4500
)
ORDER BY c.surname;


-- 8. Какие тренеры проводят занятия по йоге?
-- expect: rows
SELECT
    t.id,
    t.name,
    t.surname
FROM trainers t
WHERE EXISTS (
    SELECT 1
    FROM classes cl
    WHERE cl.trainer_id = t.id
      AND cl.name = 'Йога'
)
ORDER BY t.surname;


-- 9. Как изменится расписание тренера после добавления нового занятия?
-- expect: rows 1
BEGIN;

SELECT COUNT(*) AS classes_before
FROM classes
WHERE trainer_id = 1;

INSERT INTO classes (
    trainer_id, name, starts_at, ends_at, capacity
)
VALUES (
    1,
    'Йога',
    TIMESTAMPTZ '2026-10-31 10:00:00+10',
    TIMESTAMPTZ '2026-10-31 11:00:00+10',
    15
);

SELECT COUNT(*) AS classes_after
FROM classes
WHERE trainer_id = 1;

ROLLBACK;


-- 10. Как изменится цена первого абонемента после повышения на 500 рублей?
-- expect: rows 1
BEGIN;

SELECT id, price AS price_before
FROM memberships
WHERE id = 1;

UPDATE memberships
SET price = price + 500
WHERE id = 1;

SELECT id, price AS price_after
FROM memberships
WHERE id = 1;

ROLLBACK;


-- 11. Что произойдёт с записью клиента 10 на занятие 10 при её удалении?
-- expect: rows 1
BEGIN;

SELECT COUNT(*) AS registrations_before
FROM registrations
WHERE client_id = 10 AND class_id = 10;

DELETE FROM registrations
WHERE client_id = 10 AND class_id = 10;

SELECT COUNT(*) AS registrations_after
FROM registrations
WHERE client_id = 10 AND class_id = 10;

ROLLBACK;


-- 12. Какие клиенты приобрели абонементы дороже средней стоимости?
-- expect: rows
SELECT
    c.name,
    c.surname,
    m.price
FROM clients c
JOIN memberships m ON m.client_id = c.id
WHERE m.price > (
    SELECT AVG(price)
    FROM memberships
)
ORDER BY m.price DESC, c.surname;

-- 13. Какие три занятия наиболее популярны в каждой категории?
-- expect: rows
WITH class_popularity AS (
    SELECT
        cl.id,
        cl.name AS category,
        cl.starts_at,
        COUNT(r.id) AS registrations_count
    FROM classes cl
    LEFT JOIN registrations r ON r.class_id = cl.id
    GROUP BY cl.id, cl.name, cl.starts_at
),
ranked_classes AS (
    SELECT
        id,
        category,
        starts_at,
        registrations_count,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY registrations_count DESC, starts_at
        ) AS position
    FROM class_popularity
)
SELECT
    category,
    starts_at,
    registrations_count,
    position
FROM ranked_classes
WHERE position <= 3
ORDER BY category, position;



-- 14. Как накапливается общая стоимость абонементов по дате их начала?
-- expect: rows
SELECT
    id,
    starts_at,
    price,
    SUM(price) OVER (
        ORDER BY starts_at, id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_sum
FROM memberships
ORDER BY starts_at, id;