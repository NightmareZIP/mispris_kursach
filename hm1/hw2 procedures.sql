--добавить перечисление
CREATE OR REPLACE FUNCTION insert_enum
(
    name VARCHAR(100),
    short_name VARCHAR(15)
)
RETURNS mispris.public.enum
LANGUAGE SQL
AS $$
    INSERT INTO enum("name", "short_name")
    VALUES (name, short_name) RETURNING *;
$$;

--удалить перечисление
CREATE OR REPLACE FUNCTION delete_enum
(
   delete_id INT
)
RETURNS mispris.public.enum
LANGUAGE SQL
AS $$
   DELETE FROM enum WHERE id = delete_id RETURNING *;
$$;

--изменить перечисление
CREATE OR REPLACE FUNCTION alter_enum
(
    alt_id INT,
    alt_name VARCHAR(100),
    alt_short_name VARCHAR(15)
)
RETURNS mispris.public.enum
LANGUAGE SQL
AS $$
    UPDATE enum SET
                                   name = alt_name,
                                   short_name = alt_short_name
    WHERE id = alt_id RETURNING *;
$$;

--добавить элемент перечисление
CREATE OR REPLACE FUNCTION insert_enum_val
(
    new_id_enum INTEGER,
    new_val INTEGER,
    new_position INTEGER,
    new_name VARCHAR(100),
    new_short_name VARCHAR(15)
)
RETURNS mispris.public.enum_val
LANGUAGE SQL
AS $$
    INSERT INTO enum_val(id_enum, val, position,  name, short_name)
    VALUES (new_id_enum, new_val, new_position, new_name, new_short_name) RETURNING *;
$$;

--удалить элемент перечисление
CREATE OR REPLACE FUNCTION delete_enum_val
(
   delete_id INT
)
RETURNS mispris.public.enum_val
LANGUAGE SQL
AS $$
   DELETE FROM enum_val WHERE id = delete_id RETURNING *;
$$;

--изменить элемент перечисление
CREATE OR REPLACE FUNCTION alter_enum_val
(
    find_id INTEGER,
    new_id_enum INTEGER,
    new_val INTEGER,
    new_position INTEGER,
    new_name VARCHAR(100),
    new_short_name VARCHAR(15)
)
RETURNS mispris.public.enum_val
LANGUAGE SQL
AS $$
    UPDATE enum_val SET
                id_enum =new_id_enum ,
                val = new_val ,
                position = new_position ,
                name = new_name,
                short_name = new_short_name
    WHERE id = find_id RETURNING *;
$$;

--Изменить позицию ВВЕРХ меняет местами порядковый номер указанного элемента и
--элемента с максимальной позицией
CREATE OR REPLACE FUNCTION change_position_up
(
    find_id INTEGER
)
RETURNS mispris.public.enum_val
LANGUAGE plpgsql
AS $$
    DECLARE
        max_row enum_val;
        current_row enum_val;
        enum_id INT;
    BEGIN
    SELECT id_enum FROM enum_val  WHERE id = find_id INTO enum_id;

    SELECT * FROM enum_val  WHERE id = find_id INTO current_row;
    SELECT * FROM enum_val
             WHERE position = (SELECT MAX(position) FROM enum_val WHERE id_enum = enum_id)
             INTO max_row;
    UPDATE enum_val SET position = max_row.position WHERE id = current_row.id;
    UPDATE enum_val SET position = current_row.position WHERE id = max_row.id;
    END
$$;

--Изменить позицию ВНИЗ меняет местами порядковый номер указанного элемента и
--элемента с минимальной позицией
CREATE OR REPLACE FUNCTION change_position_down
(
    find_id INTEGER
)
RETURNS mispris.public.enum_val
LANGUAGE plpgsql
AS
$$
    DECLARE
        min_row enum_val;
        current_row enum_val;
        enum_id INT;
    BEGIN
    SELECT id_enum FROM enum_val  WHERE id = find_id INTO enum_id;

    SELECT * FROM enum_val  WHERE id = find_id INTO current_row;
    SELECT * FROM enum_val
             WHERE position = (SELECT MIN(position) FROM enum_val WHERE id_enum = enum_id)
             INTO min_row;
    UPDATE enum_val SET position = min_row.position WHERE id = current_row.id;
    UPDATE enum_val SET position = current_row.position WHERE id = min_row.id;
    END
$$;
