--
SELECT * FROM insert_unit_of_measurement('Миллиметр', 'мм');
SELECT * FROM insert_unit_of_measurement('Метр', 'м');
SELECT * FROM insert_unit_of_measurement('Квадратный метр', 'м2');
SELECT * FROM insert_unit_of_measurement('Килограмм', 'кг');
SELECT * FROM insert_unit_of_measurement('Тонна', 'т');

--
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



--

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




/*

-- Если нужно больше данных

SELECT * FROM insert_product(13,  '№18a h180,b100,d5.1,t8.3');
SELECT * FROM insert_product(13,  '№60 h600,b190,d12,t17.8');
SELECT * FROM insert_product(14,  '№18a h180,b100,d5.1,t8.1');
SELECT * FROM insert_product(14,  '№70б h700,b210,d17.5,t28.2');
SELECT * FROM insert_product(16,  '№18a h180,b74,d5.1,t9.3');
SELECT * FROM insert_product(16,  '№40 h400,b150,d8.0,t13.5');
SELECT * FROM insert_product(15,  '№18a h180,b74,d5.1,t9.3');
SELECT * FROM insert_product(15,  '№40 h400,b150,d8.0,t13.5');
SELECT * FROM insert_product(8,  '№7 b70, d6');
SELECT * FROM insert_product(8,  '№7 b70, d8');
SELECT * FROM insert_product(8,  '№25 b250, d30');
SELECT * FROM insert_product(9,  '№7 b70, d8');
SELECT * FROM insert_product(9,  '№25 b250, d30');
SELECT * FROM insert_product(18,  '№ 7,5/5; B75; b50; d6');
SELECT * FROM insert_product(18,  '№ 25/16; B250; b160; d20');
SELECT * FROM insert_product(17,  '№ 7,5/5; B75; b60; t6; R8,0; r2,7');
SELECT * FROM insert_product(17,  '№ 20/12,5; B200; b125; t12; R14,0; r4,7');
SELECT * FROM insert_product(10,  'D32x4,5');
SELECT * FROM insert_product(10,  'D42x5');
SELECT * FROM insert_product(11,  '120x5');
SELECT * FROM insert_product(11,  '160x7');
SELECT * FROM insert_product(12,  '160x120x4');
SELECT * FROM insert_product(12,  '200x160x7');

*/