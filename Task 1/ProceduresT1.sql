--Процедуры добавления--
--Единица измерения
CREATE OR REPLACE FUNCTION insert_unit_of_measurement
(
    name VARCHAR(30),
    short_name VARCHAR(20))
RETURNS unit_of_measurement
LANGUAGE SQL
AS $$
    INSERT INTO unit_of_measurement ("name", "short_name")
    VALUES (name, short_name) RETURNING *;
$$;

--Класс продукта
CREATE OR REPLACE FUNCTION insert_product_class(
    parent_id INT,
    name VARCHAR(30),
    short_name VARCHAR(20),
    measurement_id INT
)
RETURNS product_class
LANGUAGE SQL
AS $$
    INSERT INTO product_class ("parent_id", "name", "short_name", "measurement_id")
    VALUES (parent_id, name, short_name, measurement_id) RETURNING *;
$$;

--Продукт
CREATE OR REPLACE FUNCTION insert_product(
    class_id INT,
    name VARCHAR(250)
)
RETURNS product
LANGUAGE SQL
AS $$
    INSERT INTO product ("class_id", "name")
    VALUES (class_id, name) RETURNING *;
$$;

--Процедуры удаления--
--Единица измерения
CREATE OR REPLACE FUNCTION delete_unit_of_measurement
(
   delete_id INT
)
RETURNS unit_of_measurement
LANGUAGE SQL
AS $$
   DELETE FROM unit_of_measurement WHERE id = delete_id RETURNING *;
$$;

--Класс продукта
--удаление класса продукта
CREATE OR REPLACE FUNCTION delete_product_class
(
   delete_id INT
)
RETURNS product_class
LANGUAGE plpgsql
AS $$
    DECLARE
    deleted_product product_class;
    del_parent_id int default null;
    BEGIN

    select product_class.parent_id into del_parent_id from product_class where id = delete_id;
    update product_class set parent_id = del_parent_id where parent_id = delete_id;
    delete from product_class where id = delete_id returning * into deleted_product;
    return deleted_product;
END
$$;

--Продукт
CREATE OR REPLACE FUNCTION delete_product
(
   delete_id INT
)
RETURNS product
LANGUAGE SQL
AS $$
   DELETE FROM product WHERE id = delete_id RETURNING *;
$$;

--Процедуры изменения--
--Единица измерения
CREATE OR REPLACE FUNCTION alter_unit_of_measurement
(
    alt_id INT,
    alt_name VARCHAR(30),
    alt_short_name VARCHAR(20))
RETURNS unit_of_measurement
LANGUAGE SQL
AS $$
    UPDATE unit_of_measurement SET
                                   name = alt_name,
                                   short_name = alt_short_name
    WHERE id = alt_id RETURNING *;
$$;

--Класс продукта
CREATE OR REPLACE FUNCTION alter_product_class(
    alt_id INT,
    alt_parent_id INT,
    alt_name VARCHAR(60),
    alt_short_name VARCHAR(20),
    alt_measurement_id INT
)
RETURNS product_class
LANGUAGE SQL
AS $$
    SELECT *  FROM product_class_change_parent(alt_id, alt_parent_id);
    UPDATE product_class SET
                                   name = alt_name,
                                   short_name = alt_short_name,
                                   measurement_id = alt_measurement_id
    WHERE id = alt_id RETURNING *;
$$;

--Продукт
CREATE OR REPLACE FUNCTION alter_product(
    alt_id INT,
    alt_class_id INT,
    alt_name VARCHAR(30)
)
RETURNS product
LANGUAGE SQL
AS $$
    UPDATE product SET
                                   class_id = alt_class_id,
                                   name = alt_name
    WHERE id = alt_id RETURNING *;
$$;

--найти родителя
CREATE OR REPLACE FUNCTION product_class_find_parent
(
   ent_id INT
)
RETURNS product_class
LANGUAGE SQL
AS $$
    SELECT * FROM  product_class WHERE id = (SELECT parent_id FROM product_class WHERE id = ent_id) ;
$$;

--найти потомков первого уровня
create or replace FUNCTION product_class_find_children
(
	root_id INT
)
RETURNS TABLE (
    id INT,
    parent_id INT,
    name VARCHAR(60),
    short_name VARCHAR(30),
    measurement_id INT
)
LANGUAGE SQL
AS $$
    SELECT * FROM product_class WHERE parent_id = root_id;
$$;

-- Функция проверки на цикл.
CREATE OR REPLACE FUNCTION is_cycle(class_id INTEGER, new_parent INTEGER)
    RETURNS BOOLEAN
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN (SELECT EXISTS(WITH RECURSIVE descendants AS (
        SELECT id, name, parent_id
        FROM product_class
        WHERE id = new_parent

        UNION
        SELECT P.id,
               P.name,
               P.parent_id
        FROM product_class AS P
                 INNER JOIN descendants D ON D.parent_id = P.id
    )
      SELECT *
      FROM descendants
      WHERE id = class_id));
END
$$;

-- Смена родителя (вершины)
-- child_id - идентификатор дочернего класса, родителя которого хотят поменять
-- to_parent_id - идентификатор родителя, который будет родителем from_id
-- При неуспешной смене бросается исключение
CREATE OR REPLACE FUNCTION product_class_change_parent(class_id INTEGER, new_parent INTEGER)
    RETURNS product_class
    LANGUAGE plpgsql
    AS
$$
DECLARE
    result product_class;
    HAS_CYCLE BOOLEAN DEFAULT FALSE;
BEGIN
    HAS_CYCLE := is_cycle(class_id, new_parent);
    IF HAS_CYCLE THEN
        RAISE EXCEPTION 'ЦИКЛ! Отмена операции';
    ELSE
        UPDATE product_class SET parent_id = new_parent WHERE id = class_id RETURNING * into result;
    END IF;
    return result;
END;
$$;
