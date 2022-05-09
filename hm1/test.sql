--
SELECT * FROM insert_unit_of_measurement('Грамм', 'г');
SELECT * FROM insert_unit_of_measurement('Литр', 'л');

SELECT * FROM alter_unit_of_measurement(1, 'Кило', 'кг');
SELECT * FROM delete_unit_of_measurement(2);
SELECT * FROM insert_unit_of_measurement('Грамм', 'г');

-- Пока забиваем на селекты, оставлю просто пример реализации
--SELECT * FROM select_unit_of_measurement();
SELECT * FROM unit_of_measurement;
--
SELECT * FROM insert_product_class(NULL, 'Сталь гор', 'Стг', 3);
SELECT * FROM insert_product_class(1, 'Труба Сталь ', 'Тр', 3);
SELECT * FROM insert_product_class(2, 'Труба Сталь круг ', 'Трск', 3);

SELECT * FROM alter_product_class(2, 1,'Банка', 'Б', 1);
SELECT * FROM product_class_find_parent(2);
SELECT * FROM product_class_set_parent(2, NULL);
SELECT * FROM delete_product_class(2);

SELECT * FROM product_class;

SELECT * FROM insert_product(3,  'Трубка');
SELECT * FROM insert_product(1, 'Трубочка');
SELECT * FROM delete_product(1);

SELECT * FROM alter_product(2, 1,'Трррррр');


SELECT * FROM product;
