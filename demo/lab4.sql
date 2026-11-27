
-- 1. Запоминаем исходное название занятия № 1
-- expect: rows 1
SELECT name
FROM classes
WHERE id = 1;


-- 2. Начинаем транзакцию и изменяем занятие
BEGIN;

UPDATE classes
SET name = name || ' (rollback test)'
WHERE id = 1;

-- expect: error fk
-- Пытаемся записать несуществующего клиента
INSERT INTO registrations (client_id, class_id)
VALUES (-1, 1);

-- Откатываем транзакцию
ROLLBACK;


-- 3. Проверяем, что название занятия не изменилось
-- expect: same 1
SELECT name
FROM classes
WHERE id = 1;


-- 4. Проверяем, что app_reader не может читать таблицу clients
SET ROLE app_reader;

-- expect: error
SELECT *
FROM clients
LIMIT 1;

RESET ROLE;


-- 5. Проверяем, что app_writer не может напрямую добавлять записи
SET ROLE app_writer;

-- expect: error
INSERT INTO registrations (client_id, class_id)
VALUES (1, 1);

RESET ROLE;
