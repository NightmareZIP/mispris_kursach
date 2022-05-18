DROP TABLE IF EXISTS enum CASCADE;
DROP TABLE IF EXISTS enum_val CASCADE ;
CREATE TABLE enum(
    id INT GENERATED ALWAYS AS IDENTITY, /*Ид. перечисления*/
    PRIMARY KEY (id),
    name VARCHAR(100),       /*Имя перечисления*/
    short_name VARCHAR(15)       /*Обозначение перечисления*/
);
CREATE TABLE enum_val (
    id INT GENERATED ALWAYS AS IDENTITY,   /*Код значения*/
    PRIMARY KEY (id),
    id_enum INTEGER ,   /*Ид. перечисления*/
    FOREIGN KEY (id_enum)
        REFERENCES enum(id)
        ON DELETE CASCADE, /*При удалении перечисления удаляем все элементы*/
    --val  INTEGER,    /*Численное значение*/ Будет свое для каждого свойства
    position INTEGER NOT NULL ,   /*Порядковый номер значения*/
    short_name  VARCHAR(15),        /*Обозначение значения*/
    name VARCHAR(150)       /*Имя значения*/
);
