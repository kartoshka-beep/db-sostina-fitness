-- [setup] Подготавливаем занятие, на котором есть одно свободное место
DELETE FROM classes
WHERE name = 'race-test';

INSERT INTO classes (trainer_id, name, starts_at, ends_at, capacity)
VALUES (
    (SELECT id FROM trainers ORDER BY id LIMIT 1),
    'race-test',
    NOW() + INTERVAL '1 day',
    NOW() + INTERVAL '2 days',
    1
);


-- [A] Окно A: первый клиент записывается на занятие
BEGIN;

INSERT INTO registrations (client_id, class_id)
SELECT
    (SELECT id FROM clients ORDER BY id LIMIT 1),
    id
FROM classes
WHERE name = 'race-test';


-- [B] Окно B: второй клиент одновременно записывается на то же занятие
BEGIN;

INSERT INTO registrations (client_id, class_id)
SELECT
    (SELECT id FROM clients ORDER BY id LIMIT 1 OFFSET 1),
    id
FROM classes
WHERE name = 'race-test';


-- [A] Подтверждаем первую запись
COMMIT;


-- [B] Подтверждаем вторую запись
COMMIT;


-- [check] Проверяем, превышено ли количество мест
-- expect: false
SELECT
    COUNT(r.id) <= c.capacity AS capacity_is_respected
FROM classes c
LEFT JOIN registrations r ON r.class_id = c.id
WHERE c.name = 'race-test'
GROUP BY c.id, c.capacity;


-- [cleanup] Удаляем тестовое занятие
DELETE FROM classes
WHERE name = 'race-test';