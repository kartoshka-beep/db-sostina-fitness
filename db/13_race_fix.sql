CREATE OR REPLACE FUNCTION register_client_safe(
    p_client_id INTEGER,
    p_class_id INTEGER
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_capacity INTEGER;
    v_registered INTEGER;
BEGIN
    -- Проверяем существование клиента
    IF NOT EXISTS (
        SELECT 1
        FROM clients
        WHERE id = p_client_id
    ) THEN
        RAISE EXCEPTION 'Клиент с ID % не найден', p_client_id;
    END IF;

    -- Блокируем строку занятия до завершения транзакции
    SELECT capacity
    INTO v_capacity
    FROM classes
    WHERE id = p_class_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Занятие с ID % не найдено', p_class_id;
    END IF;

    -- Считаем количество уже записанных клиентов
    SELECT COUNT(*)
    INTO v_registered
    FROM registrations
    WHERE class_id = p_class_id;

    -- Проверяем наличие свободных мест
    IF v_registered >= v_capacity THEN
        RAISE EXCEPTION 'На занятии с ID % нет свободных мест', p_class_id;
    END IF;

    -- Записываем клиента
    INSERT INTO registrations (client_id, class_id)
    VALUES (p_client_id, p_class_id);
END;
$$;