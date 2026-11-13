-- Функция 1. Количество свободных мест на занятии
CREATE OR REPLACE FUNCTION get_available_places(p_class_id INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_capacity INTEGER;
    v_registered INTEGER;
BEGIN
    SELECT capacity
    INTO v_capacity
    FROM classes
    WHERE id = p_class_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Занятие с ID % не найдено', p_class_id;
    END IF;

    SELECT COUNT(*)
    INTO v_registered
    FROM registrations
    WHERE class_id = p_class_id;

    RETURN v_capacity - v_registered;
END;
$$;


-- Функция 2. Запись клиента на занятие
CREATE OR REPLACE FUNCTION register_client(
    p_client_id INTEGER,
    p_class_id INTEGER
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM clients WHERE id = p_client_id
    ) THEN
        RAISE EXCEPTION 'Клиент с ID % не найден', p_client_id;
    END IF;

    IF get_available_places(p_class_id) <= 0 THEN
        RAISE EXCEPTION 'На занятии с ID % нет свободных мест', p_class_id;
    END IF;

    INSERT INTO registrations (client_id, class_id)
    VALUES (p_client_id, p_class_id);
END;
$$;