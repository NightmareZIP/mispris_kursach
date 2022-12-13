
CREATE TABLE EI
(
	ID_EI serial NOT NULL PRIMARY KEY,
	short_name_EI text NOT NULL,
	name_EI text NOT NULL
);

CREATE TABLE class_izdeliy
(
	ID_class serial NOT NULL PRIMARY KEY,
	short_name text NOT NULL,
	name text NOT NULL,
	prnt_ID integer,
	EI_ID integer,
	    CONSTRAINT EI_ID
	    FOREIGN KEY (EI_ID) REFERENCES EI (ID_EI) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
        CONSTRAINT prnt_ID
	    FOREIGN KEY (prnt_ID) REFERENCES class_izdeliy (ID_class) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

CREATE TABLE product
(
    ID_prod  serial  NOT NULL PRIMARY KEY,
    short_name_proD text    NOT NULL,
    name_proD       text    NOT NULL,
    class_ID        integer NOT NULL,
    CONSTRAINT class_ID FOREIGN KEY (class_ID)
        REFERENCES class_izdeliy (ID_class) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

CREATE TABLE specprod
(
    id_prod_general integer NOT NULL,
    position_number integer NOT NULL,
    id_prod_part    integer NOT NULL,
    quantity        integer NOT NULL,
    CONSTRAINT id_prod_general FOREIGN KEY (id_prod_general)
        REFERENCES product (ID_prod) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT id_prod_part FOREIGN KEY (id_prod_part)
        REFERENCES product (ID_prod) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);


    CREATE OR REPLACE function add_ei (short_name text, full_name text ) RETURNS VOID
as $$
begin
  INSERT INTO ei(short_name_EI, name_EI) VALUES ($1, $2);
end $$ LANGUAGE plpgsql;

CREATE OR REPLACE function add_class (class_short_name text, full_name text, parent integer, ei integer) RETURNS VOID
as $$
begin
  INSERT INTO class_izdeliy(short_name, name, prnt_ID, EI_ID) VALUES ($1, $2, $3, $4);
end $$ LANGUAGE plpgsql;

CREATE OR REPLACE function add_prod(short_prod_name text, full_prod_name text, id_class integer) RETURNS VOID
as
$$
begin
    INSERT INTO product(short_name_proD, name_proD, class_ID) VALUES ($1, $2, $3);
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE function add_specprod(id_prod_general integer, position_number integer, id_prod_part integer, quantity integer) RETURNS VOID
as
$$
begin
    INSERT INTO specprod(id_prod_general, position_number, id_prod_part, quantity)
    VALUES ($1, $2, $3, $4);
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE function change_parent_class (id_need_to_update integer, new_parent integer) RETURNS TEXT
as $$
begin
/*проверяем если новый родитель существует и не равен старому*/
    IF ((new_parent IS NOT NULL) AND (id_need_to_update != new_parent)) THEN
        IF (search_for_cycle (id_need_to_update, new_parent ) = 1) THEN /*проверяем на потенциальный цикл*/
            RETURN 'Невозможно выполнить операцию во избежания зацикливания';
        ELSE
            UPDATE class_izdeliy SET prnt_id = new_parent WHERE id_class = id_need_to_update;
            RETURN 'Операция выполнена';
        end if;
    ELSE
        RETURN 'Невозможно выполнить операцию';
    END IF;
end $$ LANGUAGE plpgsql;



CREATE OR REPLACE function search_for_cycle (id_need_to_update integer, new_parent integer) RETURNS INTEGER
as $$
    DECLARE yes_circle INTEGER; /*переменная наличия цикла*/
    DECLARE X INTEGER; /*запоминаем родителя того класса, у которого хотим изменить*/
    DECLARE Y INTEGER; /*айди класса, у которого хотим сменить родителя*/
    DECLARE Z INTEGER; /*переменная для запоминания id родителя в цикле*/
begin
        Y = id_need_to_update;
        X := (SELECT prnt_ID from class_izdeliy where ID_class = id_need_to_update);
        UPDATE class_izdeliy SET prnt_ID = new_parent WHERE ID_class = id_need_to_update;
        yes_circle = 0;
        Z = -1;
        while (Z != id_need_to_update OR Z IS NULL) /*если зациклились или дошли до самого верха, то останавливаем while*/
        loop
            Z := (SELECT prnt_ID from class_izdeliy where ID_class = Y); /*двигаемся по дереву от сына к родителю*/
            Y := Z;
        end loop;
        IF (Z = id_need_to_update) THEN
            yes_circle = 1; /*если зациклились, то указываем, что нашли цикл*/
            UPDATE class_izdeliy SET prnt_ID = X WHERE ID_class = id_need_to_update;
        END IF;
        RETURN yes_circle; /*возвращаем 0 - нет цикла, 1 - есть цикл*/
end $$ LANGUAGE plpgsql;

CREATE OR REPLACE function change_prod_class (id_prdct integer, new_class integer) RETURNS TEXT
as $$
begin
    IF (new_class IS NOT NULL) THEN
        UPDATE product SET class_ID = new_class WHERE ID_prod = id_prdct;
        RETURN 'Операция выполнена';
    ELSE
        RETURN 'Невозможно выполнить операцию';
    END IF;
end $$ LANGUAGE plpgsql;

CREATE OR REPLACE function delete_class (delete_id integer) RETURNS TEXT
as $$
begin
    IF EXISTS (SELECT prnt_ID FROM class_izdeliy WHERE prnt_ID = delete_id) THEN
        RETURN 'Невозможно выполнить операцию. Необходимо сначала сменить родителей у потомков, а затем удалить класс';
    ELSIF EXISTS (SELECT ID_prod FROM product WHERE class_ID = delete_id) THEN
        RETURN 'Невозможно выполнить операцию. Необходимо сначала сменить родителей у потомков, а затем удалить класс';
    ELSE
        DELETE FROM class_izdeliy WHERE ID_class = delete_id;
        RETURN 'Операция выполнена';
    END IF;
end $$ LANGUAGE plpgsql;

CREATE OR REPLACE function delete_prod (delete_id integer) RETURNS VOID
as $$
begin
  DELETE FROM product WHERE ID_prod = delete_id;
end $$ LANGUAGE plpgsql;

/*вход: id класса выход: дерево значений класса*/
CREATE OR REPLACE function showtree(INTEGER)
RETURNS  table (id_class integer, name_class text, name_product text) as $$
begin
RETURN QUERY
/*берем стартовые данные*/
WITH RECURSIVE tab1 (id_class, parent_id, name_class, path) AS (
SELECT t1.id_class, t1.prnt_id, t1.name, CAST (t1.name AS TEXT) as PATH
    FROM class_izdeliy t1 WHERE t1.id_class=$1
Union
/*подставляем в рекурсивную часть запроса*/
SELECT t2.id_class, t2.prnt_id, t2.name, CAST ( tab1.PATH ||' = > '|| t2.name AS TEXT)
     FROM class_izdeliy t2 INNER JOIN tab1 ON( tab1.id_class = t2.prnt_id) )
SELECT c.id_class, c.path, p.name_prod as name_product
FROM tab1 as c LEFT JOIN product as p on c.id_class=p.class_id
/*возвращаем результат*/
ORDER BY path, p.name_prod;
end;
$$ LANGUAGE plpgsql;

/*вход: id продукта, спецификацию которого хотим получить выход: имя продукции, номер позиции, имя входящего продукта и кол-во*/
CREATE OR REPLACE function showspec(integer)
    returns table
            (
                name_proD       text,
                position_number integer,
                name_product    text,
                quantity        integer
            )
as
$$
begin
    RETURN QUERY
        with recursive tab1(id_prod_general, position_number, id_prod_part, quantity, name_proD, path) AS
                           (SELECT s.id_prod_general, s.position_number, s.id_prod_part,
                                   s.quantity, p.name_proD, cast(s.id_prod_part as text) as path
                            FROM specprod s
                                     join product as p on s.id_prod_part = p.ID_prod
                            WHERE s.id_prod_general = $1
                            union
                            select s2.id_prod_general, s2.position_number, s2.id_prod_part,
                                   s2.quantity, p.name_proD, cast(tab1.path || '->' || s2.id_prod_general as text)
                            from specprod s2
                                     join product as p on s2.id_prod_part = p.ID_prod
                                     JOIN tab1 ON (tab1.id_prod_part = s2.id_prod_general))
        select (select product.name_proD from product where tab3.id_prod_general = product.ID_prod), tab3.position_number, p.name_proD as name_product,
               tab3.quantity
        from tab1 as tab3
                 join product as p on tab3.id_prod_part = p.ID_prod
        ORDER BY PATH, p.name_proD;
end;
$$ LANGUAGE plpgsql;
/*вход: id продукта и желаемое кол-во выход: продукция и количество, в котором они нужны*/
CREATE OR REPLACE function countClassAmount(id_prod integer, amount integer)
    returns table
            (
                name       text,
                quantity   integer
            )
as
$$
begin
     RETURN QUERY
        with recursive tab1(id_prod_general, id_prod_part, quantity, name_proD) AS
                           (SELECT s.id_prod_general,
                                   s.id_prod_part,
                                   s.quantity*$2 as cnt,
                                   p.name_proD
                            FROM specprod s
                                     join product as p on s.id_prod_part = p.ID_prod
                            WHERE s.id_prod_general = $1
                            union
                            select s2.id_prod_general,
                                   s2.id_prod_part,
                                   s2.quantity*tab1.quantity as totalcnt,
                                   p.name_proD
                            from specprod s2
                                     join product as p on s2.id_prod_part = p.ID_prod
                                     JOIN tab1 ON (tab1.id_prod_part = s2.id_prod_general))
        select p.name_proD as name_product,
               tab3.quantity
        from tab1 as tab3
                 join product as p on tab3.id_prod_part = p.ID_prod;
end;
$$ LANGUAGE plpgsql;


select countClassAmount(3,2);

SELECT add_ei('шт','штуки');
SELECT add_ei('кг','килограммы');

SELECT add_class('Изд','Изделия', null, null);
SELECT add_class('Изд_для_сна','Изделия для сна', 1, null);
SELECT add_class('Крвт','Кровати', 2, null);
SELECT add_class('КрвтДв','Кровать двуспальная', 3, 1);
SELECT add_prod('КрвтСМягИзг','Кровать с мягким изголовьем',4);
SELECT add_prod('КрвтСВысИзг','Кровать с высоким изголовьем',4);
SELECT add_class('КрвтОдн','Кровать односпальная', 3, 1);
SELECT add_prod('КрвтБезПодМех','Кровать без подъемного механизма',5);
SELECT add_prod('КрвтСПодМех','Кровать с подъемным механизмом',5);
SELECT add_class('СоставЭл','Составные элементы', 1, null);
SELECT add_class('Матрас','Матрас', 6, 1);
SELECT add_prod('МатрасБес','Матрас беспружинный',7);
SELECT add_prod('МатрасСПБ','Матрас с пружинным блоком',7);
SELECT add_class('Каркас','Каркас', 6, 1);
SELECT add_prod('Дерев','Деревянный каркас',8);
SELECT add_prod('Металл','Металлический каркас',8);
SELECT add_class('Изг','Изголовье', 6, 1);
SELECT add_prod('МягИзг','Мягкое изголовье',9);
SELECT add_prod('ВысИзг','Высокое изголовье',9); 
SELECT add_class('Креп','Крепеж', 6, 1);
SELECT add_prod('Саморез','Саморез',10);
SELECT add_prod('Стяжка','Стяжка',10);

SELECT add_specprod(2,1,6,1);
SELECT add_specprod(2,2,7,2);
SELECT add_specprod(3,1,6,1);
SELECT add_specprod(3,2,8,1);
SELECT add_specprod(8,1,9,2);
SELECT add_specprod(7,1,11,12);
SELECT add_specprod(7,1,12,11);
