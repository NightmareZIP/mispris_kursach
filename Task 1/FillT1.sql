SELECT * FROM insert_unit_of_measurement('Миллиметр', 'мм');
SELECT * FROM insert_unit_of_measurement('Метр', 'м');
SELECT * FROM insert_unit_of_measurement('Квадратный метр', 'м2');
SELECT * FROM insert_unit_of_measurement('Килограмм', 'кг');
SELECT * FROM insert_unit_of_measurement('Тонна', 'т');

SELECT * FROM insert_product_class(NULL, 'Прокатная сталь', 'ПрСт', 1);
SELECT * FROM insert_product_class(1, 'Сталь горячекатная', 'ГпСт', 1);
SELECT * FROM insert_product_class(1, 'Сталь прокатная угловая', 'ПрУгСт', 1);
SELECT * FROM insert_product_class(1, 'Трубы', 'Трб', 1);
SELECT * FROM insert_product_class(2, 'Балки двутавровые', '', 1);
SELECT * FROM insert_product_class(2, 'Швеллеры', '', 1);
SELECT * FROM insert_product_class(3, 'Угловая неравнополочная', '', 1);
SELECT * FROM insert_product_class(3, 'Угловая равнополочная ГОСТ 8509-72', '', 1);
SELECT * FROM insert_product_class(3, 'Угловая равнополочная ГОСТ 8509-93', '', 1);
SELECT * FROM insert_product_class(4, 'Трубы сокращенные ГОСТ 10704-91', '', 1);
SELECT * FROM insert_product_class(4, 'Трубы квадратные ТУ 36-2287-80', '', 1);
SELECT * FROM insert_product_class(4, 'Трубы прямоугольные ТУ 67-2287-80', '', 1);
SELECT * FROM insert_product_class(5, 'Балки двутавровые ГОСТ 8239-72', '', 1);
SELECT * FROM insert_product_class(5, 'Балки двутавровые ГОСТ 8239-89', '', 1);
SELECT * FROM insert_product_class(6, 'Швеллеры ГОСТ 8240-97', '', 1);
SELECT * FROM insert_product_class(6, 'Швеллеры с уклоном внутренних граней полок ГОСТ 8240-72', '', 1);
SELECT * FROM insert_product_class(7, 'Угловая неравнополочная ГОСТ 8510-86', '', 1);
SELECT * FROM insert_product_class(7, 'Угловая неравнополочная ГОСТ 8510-72', '', 1);

SELECT * FROM insert_product(13,  '№10 h100,b55,d4.5,t7.2');
SELECT * FROM insert_product(14,  '№10 h100,b55,d4.5,t7.2');
SELECT * FROM insert_product(16,  '№5 h50,b32,d4.4,t7.0');
SELECT * FROM insert_product(15,  '№5 h50,b32,d4.4,t7.0');
SELECT * FROM insert_product(8,  '№2 b20, d3');
SELECT * FROM insert_product(9,  '№2 b20, d3');
SELECT * FROM insert_product(9,  '№7 b70, d6');
SELECT * FROM insert_product(18,  '№ 2,5/1,6; B25; b16; d3');
SELECT * FROM insert_product(17,  '№ 2,5/1,6; B25; b16; t4; R3,5; r1,2');
SELECT * FROM insert_product(10,  'D25x3');
SELECT * FROM insert_product(10,  'D28x8');
SELECT * FROM insert_product(11,  '80x3');
SELECT * FROM insert_product(12,  '100x60x3');

