-- Добавить числовой параметр для изделия
-- param_id - идентификатор параметра
-- id_product - идентификатор изделия
-- value - значение
-- information - примечания
-- При успешных проверках добавляется параметр в таблицу par_class
-- Проверки:
--  Проверка на наличие такого параметра в классе этого изделия
--  Проверка на тип параметра (перечисление/числовой)
--  Проверка на диапазон значения параметра
DROP FUNCTION IF EXISTS add_val_paramr(integer,integer,double precision,character varying);
DROP FUNCTION IF EXISTS add_enum_val_param(integer,integer,integer,character varying);
DROP FUNCTION IF EXISTS copy_class_params(integer,integer);
DROP FUNCTION IF EXISTS aregat_content(integer);

CREATE OR REPLACE FUNCTION add_val_paramr(param_id INTEGER, id_product INTEGER, value DOUBLE PRECISION,
                                                information VARCHAR(150))
    RETURNS void
    LANGUAGE plpgsql
AS
$$
DECLARE
    param_type      INTEGER DEFAULT NULL;
    value_param_id  INTEGER DEFAULT NULL;
    id_class        INTEGER DEFAULT NULL; --с DEFAULT NULL ругается на вечную ложность любого выражения
    min_param_value INTEGER DEFAULT NULL;
    max_param_value INTEGER DEFAULT NULL;
BEGIN
    SELECT id_type INTO param_type FROM parameter WHERE id = param_id;
    SELECT id INTO value_param_id FROM type_par WHERE name = 'Числовой';
    SELECT class_id INTO id_class FROM product WHERE id = id_product;

    SELECT max_val, min_val
    INTO max_param_value, min_param_value
    FROM product_class_param
    WHERE id_param = param_id AND id_product_class = id_class ;
    IF param_type = value_param_id AND param_type IS NOT NULL THEN
        IF min_param_value IS NOT NULL THEN
            IF min_param_value <= value AND max_param_value >= value THEN
                INSERT INTO product_params (id_param, id_prod, val, info)
                VALUES (param_id, id_product ,value, information)
                ON CONFLICT (id_param, id_prod) DO UPDATE SET val = value, info = information;

            ELSE
                RAISE EXCEPTION 'Значение параметра не входит в диапазон параметров класса';
            END IF;
        ELSE
            RAISE EXCEPTION 'У класса изделий нет такого параметра';
        END IF;
    ELSE
        RAISE EXCEPTION 'Нельзя задать параметры, потому что Тип параметра и Тип значения параметра различаются';
    END IF;
END;
$$;

-- Добавить параметр перечисления для изделия
-- param_id - идентификатор параметра
-- id_product - идентификатор изделия
-- val_id - значение перечисления
-- information - примечания
-- При успешных проверках добавляется параметр в таблицу par_class
-- Проверки:
--  Проверка на наличие такого параметра в классе этого изделия
--  Проверка на тип параметра (перечисление/числовой)
--  Проверка на принадлежность значения к нужному перечислению

CREATE OR REPLACE FUNCTION add_enum_val_param(param_id INTEGER, id_product INTEGER, val_id INTEGER,
                                                    information VARCHAR(150))
    RETURNS void
    LANGUAGE plpgsql
AS
$$
DECLARE
    param_type     INTEGER DEFAULT NULL;
    value_param_id INTEGER DEFAULT NULL;
    enum_Id        INTEGER DEFAULT NULL;
    param_enum_id  INTEGER DEFAULT NULL;
    id_class       INTEGER DEFAULT NULL;
BEGIN
    SELECT id INTO param_type FROM type_par WHERE param_id = id;
    SELECT id INTO value_param_id FROM type_par WHERE Name = 'Перечисление';
    SELECT id INTO enum_Id FROM enum_val WHERE id = val_id;
    SELECT id_enum INTO param_enum_id FROM parameter WHERE id = param_id;
    SELECT class_id INTO id_class FROM product WHERE id = id_product;
    IF param_type = value_param_id AND param_type IS NOT NULL THEN
        IF enum_Id = param_enum_id AND enum_Id IS NOT NULL THEN
            IF EXISTS(SELECT * FROM product_class_param WHERE id_param = param_id AND id_product_class = id_class) THEN
                INSERT INTO product_params (id_param, id_prod, id_val, info)
                VALUES (param_id, id_product ,val_id, information)
                ON CONFLICT (id_param, id_prod) DO UPDATE SET id_val = val_id, info = information RETURNING *;
            ELSE
                RAISE EXCEPTION 'У класса изделий нет такого параметра';
            END IF;
        ELSE
            RAISE EXCEPTION 'Значение перечисления не принадлежит типу перечисления';
        END IF;
    ELSE
        RAISE EXCEPTION 'Нельзя задать параметры, потому что Тип параметра и Тип значения параметра различаются';
    END IF;
END;
$$;

-- Вернуть таблицу параметров для изделия
-- Prod_Id - идентификатор изделия
-- Возвращает таблицу со столбцами Имя Изделия, Группа Изделия, Параметр, Значение
CREATE OR REPLACE FUNCTION product_params(prod_id INTEGER)

    RETURNS TABLE
            (
                ИМЯ_ИЗДЕЛИЯ    VARCHAR(100),
                ГРУППА_ИЗДЕЛИЯ VARCHAR(100),
                ПАРАМЕТР       VARCHAR(100),
                ЗНАЧЕНИЕ       TEXT
            )
     LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY (SELECT product.name, pc.name, P.name, concat(pp.val, ev.name, ' ', um.short_name)
          FROM product
                  JOIN product_class pc ON pc.id = product.class_id
                  JOIN product_params pp ON product.id = pp.id_prod
                  JOIN parameter P ON pp.id_param = P.id
                  LEFT JOIN enum_val ev ON Pp.Id_Val = ev.id
                  LEFT JOIN unit_of_measurement um ON p.id_unit_of_measurement = um.id
          WHERE product.id = prod_id);
END;
$$;


-- Скопировать параметры от класса для класса
-- From_Class_Id - идентификатор класса, от которого необходимо скопировать параметры
-- To_Class_Id - идентификатор класса, в который необходимо добавить параметры
CREATE OR REPLACE FUNCTION copy_class_params(from_class_id INTEGER, to_class_id INTEGER)
    RETURNS void
    LANGUAGE plpgsql
AS
$$
DECLARE
    Par_Class_Row RECORD;
BEGIN
    FOR Par_Class_Row IN SELECT * FROM product_class_param
      WHERE id_product_class = from_class_id
        LOOP
            INSERT INTO product_class_param (id_param, id_product_class, max_val, min_val)
            VALUES (Par_Class_Row.id_param, to_class_id, Par_Class_Row.min_val, Par_Class_Row.max_val)
            ON CONFLICT (id_param, id_product_class) DO UPDATE SET
                                                                   min_val = Par_Class_Row.min_val,
                                                                   max_val = Par_Class_Row.max_val;

        END LOOP;

END;
$$;


-- Просмотреть содержимое агрегата
-- Arg_Id - идентификатор агрегата
-- Возвращает аблицу со столбцами Позиция, Краткое Имя, Имя
CREATE OR REPLACE FUNCTION aregat_content(pos INTEGER)
    RETURNS TABLE
        (p_position int,
        p_name varchar(100),
        p_short_name varchar(45)
        )

    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
        SELECT parameter.position, parameter.name, parameter.short_name
        FROM parameter
        WHERE parameter.position = pos;
END;
$$



