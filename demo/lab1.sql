-- Лаба 1. Сценарий для показа. Формат описан в docs/scenarios.md.
-- Запуск: dbcheck run demo/lab1.sql, или в psql: \i /demo/lab1.sql
--
-- Каждый шаг: строка «-- N. что показываем», под ней «-- expect: ответ базы», под ней запрос.


-- 1. Повторный email: ошибка UNIQUE
-- expect: error unique
INSERT INTO clients (
    name,
    surname,
    lastname,
    birthday,
    sex,
    phone_number,
    email
)
VALUES (
    'Тест',
    'Тестов',
    'Тестович',
    '2000-01-01',
    'мужской',
    '+79997562047',
    'anna.ivanova@example.com'
);

-- 2. Недопустимое значение пола клиента: ошибка CHECK
-- expect: error check
INSERT INTO clients (
    name,
    surname,
    lastname,
    birthday,
    sex,
    phone_number,
    email
)
VALUES (
    'Тест',
    'Тестов',
    'Тестович',
    '2000-01-01',
    'шрек',
    '+79490949001',
    'test.check@example.com'
);

-- 3. Несуществующий клиент: ошибка внешнего ключа
-- expect: error fk
INSERT INTO memberships (
    client_id,
    starts_at,
    ends_at,
    price
)
VALUES (
    9999,
    '2026-10-01 09:00:00+10',
    '2026-11-01 09:00:00+10',
    3500.00
);