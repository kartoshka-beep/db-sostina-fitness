\getenv reader_password APP_READER_PASSWORD
\getenv writer_password APP_WRITER_PASSWORD

-- Создаём роль для чтения
SELECT format(
    'CREATE ROLE app_reader LOGIN PASSWORD %L',
    :'reader_password'
)
WHERE NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = 'app_reader'
)
\gexec

-- Обновляем пароль, если роль уже существует
SELECT format(
    'ALTER ROLE app_reader PASSWORD %L',
    :'reader_password'
)
WHERE EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = 'app_reader'
)
\gexec

-- Создаём роль для записи
SELECT format(
    'CREATE ROLE app_writer LOGIN PASSWORD %L',
    :'writer_password'
)
WHERE NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = 'app_writer'
)
\gexec

SELECT format(
    'ALTER ROLE app_writer PASSWORD %L',
    :'writer_password'
)
WHERE EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = 'app_writer'
)
\gexec

-- Writer наследует права reader
GRANT app_reader TO app_writer;

-- Запрещаем доступ к таблицам и последовательностям
REVOKE ALL ON ALL TABLES IN SCHEMA public
FROM app_reader, app_writer;

REVOKE ALL ON ALL SEQUENCES IN SCHEMA public
FROM app_reader, app_writer;

-- Разрешаем чтение только представлений
GRANT USAGE ON SCHEMA public TO app_reader;

GRANT SELECT ON v_classes_info, v_memberships_info
TO app_reader;

-- Разрешаем writer читать данные, необходимые для вызова бизнес-функции
GRANT SELECT ON clients, registrations
TO app_writer;

-- Запрещаем вызов всех функций по умолчанию
REVOKE EXECUTE ON ALL ROUTINES IN SCHEMA public
FROM PUBLIC;

-- Разрешаем writer вызывать только защищённую функцию записи
GRANT EXECUTE ON FUNCTION register_client_safe(INTEGER, INTEGER)
TO app_writer;