CREATE TABLE clients (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    surname text NOT NULL,
    lastname text NOT NULL,
    birthday date,
    sex text,
    phone_number text NOT NULL,
    email text UNIQUE,

    CHECK (sex IN ('мужской', 'женский')),
    CHECK (phone_number ~ '^\+7[0-9]{10}$')
);

CREATE TABLE trainers (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    surname text NOT NULL,
    lastname text NOT NULL,
    phone_number text,
    email text UNIQUE,

    CHECK (phone_number ~ '^\+7[0-9]{10}$')
);

CREATE TABLE memberships (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_id integer NOT NULL REFERENCES clients (id) ON DELETE CASCADE,
    starts_at timestamptz NOT NULL,
    ends_at timestamptz NOT NULL,
    price numeric(10, 2) NOT NULL,

    CHECK (ends_at > starts_at),
    CHECK (price > 0)
);

CREATE TABLE classes (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    trainer_id integer NOT NULL REFERENCES trainers (id) ON DELETE RESTRICT,
    name text NOT NULL,
    starts_at timestamptz NOT NULL,
    ends_at timestamptz NOT NULL,
    capacity integer NOT NULL,

    CHECK (ends_at > starts_at),
    CHECK (capacity > 0)
);

CREATE TABLE registrations (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_id integer NOT NULL REFERENCES clients (id) ON DELETE CASCADE,
    class_id integer NOT NULL REFERENCES classes (id) ON DELETE CASCADE,

    UNIQUE (client_id, class_id)
);