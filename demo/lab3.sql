
-- 1. Просмотр занятий с информацией о тренерах
-- expect: rows
SELECT * FROM v_classes_info
ORDER BY starts_at
LIMIT 5;


-- 2. Просмотр абонементов клиентов
-- expect: rows
SELECT * FROM v_memberships_info
ORDER BY starts_at
LIMIT 5;


-- 3. Проверка количества свободных мест
-- expect: rows 1
SELECT get_available_places(1) AS available_places;


-- 4. Проверка записи клиента на занятие
-- expect: rows 1
BEGIN;

SELECT register_client(
    (
        SELECT c.id
        FROM clients c
        WHERE NOT EXISTS (
            SELECT 1
            FROM registrations r
            WHERE r.client_id = c.id
              AND r.class_id = 1
        )
        ORDER BY c.id
        LIMIT 1
    ),
    1
);
ROLLBACK;


-- 5. Проверка запрета записи при заполненном занятии
-- expect: error
BEGIN;
UPDATE classes SET capacity = 1 WHERE id = 1;
INSERT INTO registrations (client_id, class_id)
VALUES (2, 1);
ROLLBACK;


-- 6. Проверка автоматического обновления updated_at
-- expect: rows 1
BEGIN;
SELECT id, updated_at AS old_updated_at
FROM classes
WHERE id = 1;
UPDATE classes
SET name = name
WHERE id = 1;
SELECT id, updated_at AS new_updated_at
FROM classes
WHERE id = 1;
ROLLBACK;
