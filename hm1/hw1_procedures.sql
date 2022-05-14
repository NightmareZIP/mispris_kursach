--Единицы измерения

--добавить новый элемент 
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

--удалить элемент
CREATE OR REPLACE FUNCTION delete_unit_of_measurement
(
   delete_id INT
)
RETURNS unit_of_measurement
LANGUAGE SQL
AS $$
   DELETE FROM unit_of_measurement WHERE id = delete_id RETURNING *;
$$;

--изменить элемент
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

--Класс продукции
--добавить элемент
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

--удалить элемент
CREATE OR REPLACE FUNCTION delete_product_class
(
   delete_id INT
)
RETURNS product_class
LANGUAGE SQL
AS $$
   DELETE FROM product_class WHERE id = delete_id RETURNING *;
$$;

--изменить элемент
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
    UPDATE product_class SET
                                   parent_id = alt_parent_id,
                                   name = alt_name,
                                   short_name = alt_short_name,
                                   measurement_id = alt_measurement_id
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

--установить родителя
CREATE OR REPLACE FUNCTION product_class_set_parent
(
    ent_id INT,
    new_parent_id INT
)
RETURNS product_class
LANGUAGE SQL
AS $$
    UPDATE product_class SET
           parent_id = new_parent_id
    WHERE id = ent_id RETURNING *;
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

--Экземпляр продукции

--добавить продукт
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

--удалить продукт
CREATE OR REPLACE FUNCTION delete_product
(
   delete_id INT
)
RETURNS product
LANGUAGE SQL
AS $$
   DELETE FROM product WHERE id = delete_id RETURNING *;
$$;


--изменить продукт
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
