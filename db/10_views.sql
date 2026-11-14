-- Представление 1. Список занятий с информацией о тренерах
CREATE OR REPLACE VIEW v_classes_info AS
SELECT
    cl.id,
    cl.name AS class_name,
    cl.starts_at,
    cl.ends_at,
    cl.capacity,
    t.name AS trainer_name,
    t.surname AS trainer_surname
FROM classes cl
JOIN trainers t ON t.id = cl.trainer_id;


-- Представление 2. Информация об абонементах клиентов
CREATE OR REPLACE VIEW v_memberships_info AS
SELECT
    m.id,
    c.id AS client_id,
    c.name AS client_name,
    c.surname AS client_surname,
    m.starts_at,
    m.ends_at,
    m.price
FROM memberships m
JOIN clients c ON c.id = m.client_id;