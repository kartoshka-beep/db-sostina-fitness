-- [setup] Подготавливаем тестовое занятие
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


-- [A] Окно A: первый клиент записывается
BEGIN;

SELECT register_client_safe(
    (SELECT id FROM clients ORDER BY id LIMIT 1),
    (SELECT id FROM classes WHERE name = 'race-test')
);


-- [B] Окно B: второй клиент пытается записаться
BEGIN;

-- expect: blocked
-- expect: error raise
SELECT register_client_safe(
    (SELECT id FROM clients ORDER BY id LIMIT 1 OFFSET 1),
    (SELECT id FROM classes WHERE name = 'race-test')
);


-- [A] Подтверждаем первую запись
COMMIT;


-- [B] Отменяем вторую транзакцию после ошибки
ROLLBACK;


-- [check] Проверяем вместимость
-- expect: true
SELECT
    COUNT(r.id) <= c.capacity AS capacity_is_respected
FROM classes c
LEFT JOIN registrations r ON r.class_id = c.id
WHERE c.name = 'race-test'
GROUP BY c.id, c.capacity;


-- [cleanup] Удаляем тестовое занятие
DELETE FROM classes
WHERE name = 'race-test';