-- Добавление значений параметров для Балки двутавровой ГОСТ 8239-72 ( №10 h100,b55,d4.5,t7.2 )
SELECT add_val_paramr(1,1,55.0, '');
SELECT add_val_paramr(3,1,100.0, '');
SELECT add_val_paramr(5,1,12.0, '');

-- Должна вызваться ошибка
-- SELECT * FROM add_enum_val_param(1,1,1,'');

-- Копирование параметров Балки двутавровые ГОСТ 8239-72 в Балки двутавровые ГОСТ 8239-89
SELECT copy_class_params(13, 14);

-- вывод параметров для Балки двутавровые ГОСТ 8239-72
SELECT * FROM product_params(1);

-- Вывод параметров с позицией 1 (?)
SELECT * FROM aregat_content(1);

