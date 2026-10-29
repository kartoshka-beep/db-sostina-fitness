INSERT INTO clients (
    name,
    surname,
    lastname,
    birthday,
    sex,
    phone_number,
    email
)
SELECT
    'Имя' || i,
    'Фамилия' || i,
    'Отчество' || i,
    DATE '1980-01-01' + (i % 10000),
    CASE
        WHEN i % 2 = 0 THEN 'мужской'
        ELSE 'женский'
    END,
    '+7' || LPAD((9000000000 + i)::text, 10, '0'),
    'generated.client' || i || '@example.com'
FROM generate_series(1, 1000) AS s(i);


INSERT INTO trainers (
    name,
    surname,
    lastname,
    phone_number,
    email
)
SELECT
    'Тренер' || i,
    'Фамилия' || i,
    'Отчество' || i,
    '+7' || LPAD((9100000000 + i)::text, 10, '0'),
    'generated.trainer' || i || '@example.com'
FROM generate_series(1, 1000) AS s(i);


INSERT INTO memberships (
    client_id,
    starts_at,
    ends_at,
    price
)
SELECT
    ((i - 1) % 1010) + 1,
    TIMESTAMPTZ '2026-01-01 09:00:00+03' + (i % 300) * INTERVAL '1 day',
    TIMESTAMPTZ '2026-01-01 09:00:00+03' + ((i % 300) + 30) * INTERVAL '1 day',
    3000 + (i % 5) * 500
FROM generate_series(1, 1000) AS s(i);


INSERT INTO classes (
    trainer_id,
    name,
    starts_at,
    ends_at,
    capacity
)
SELECT
    ((i - 1) % 110) + 1,
    CASE
        WHEN i % 3 = 0 THEN 'Йога'
        WHEN i % 3 = 1 THEN 'Пилатес'
        ELSE 'Фитнес'
    END,
    TIMESTAMPTZ '2026-01-01 10:00:00+03' + i * INTERVAL '1 day',
    TIMESTAMPTZ '2026-01-01 11:00:00+03' + i * INTERVAL '1 day',
    10 + (i % 11)
FROM generate_series(1, 1000) AS s(i);


INSERT INTO registrations (
    client_id,
    class_id
)
SELECT
    ((i - 1) % 1010) + 1,
    ((i - 1) % 1010) + 1
FROM generate_series(1, 1000) AS s(i)
ON CONFLICT (client_id, class_id) DO NOTHING;