
-- Добавляем время последнего изменения занятия
ALTER TABLE classes
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();


-- Триггер 1. Проверка вместимости занятия
CREATE OR REPLACE FUNCTION check_class_capacity()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_registered INTEGER;
    v_capacity INTEGER;
BEGIN
    SELECT capacity
    INTO v_capacity
    FROM classes
    WHERE id = NEW.class_id;

    SELECT COUNT(*)
    INTO v_registered
    FROM registrations
    WHERE class_id = NEW.class_id;

    IF v_registered >= v_capacity THEN
        RAISE EXCEPTION 'На занятии % нет свободных мест', NEW.class_id;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_check_class_capacity ON registrations;

CREATE TRIGGER trg_check_class_capacity
BEFORE INSERT ON registrations
FOR EACH ROW
EXECUTE FUNCTION check_class_capacity();


-- Триггер 2. Автоматическое обновление updated_at
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_classes_updated_at ON classes;

CREATE TRIGGER trg_classes_updated_at
BEFORE UPDATE ON classes
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
