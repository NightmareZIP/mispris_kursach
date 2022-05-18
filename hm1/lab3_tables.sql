DROP TABLE IF EXISTS type_par CASCADE;
DROP TABLE IF EXISTS parameter CASCADE ;
DROP TABLE IF EXISTS product_params CASCADE;
DROP TABLE IF EXISTS product_class_param CASCADE ;


CREATE TABLE type_par
(
    id INT GENERATED ALWAYS AS IDENTITY,
    PRIMARY KEY (id),
    name VARCHAR(100) NOT NULL

);

CREATE TABLE parameter
(
    id INT GENERATED ALWAYS AS IDENTITY,
    PRIMARY KEY (id),

    short_name VARCHAR(45) ,
    name VARCHAR(100),
    id_unit_of_measurement INTEGER,
        FOREIGN KEY (id_unit_of_measurement)
        REFERENCES unit_of_measurement(id)
        ON UPDATE CASCADE,
    id_enum INTEGER,
        FOREIGN KEY (id_enum)
        REFERENCES enum(id)
        ON UPDATE CASCADE,
    id_type INTEGER NOT NULL,
        FOREIGN KEY (id_type)
        REFERENCES type_par(id)
        ON UPDATE CASCADE,
    position INTEGER --не вижу смысла делать под жто отдельную сущность
);

CREATE TABLE product_params
(
    id_param  INTEGER NOT NULL,
        FOREIGN KEY (id_param)
        REFERENCES parameter(id)
        ON UPDATE CASCADE,
    id_prod SERIAL  NOT NULL,
        FOREIGN KEY (id_prod)
        REFERENCES product(id)
        ON UPDATE CASCADE,
    val     DOUBLE PRECISION,
    id_val  INTEGER,
        FOREIGN KEY (id_prod)
        REFERENCES product(id)
        ON UPDATE CASCADE,
    info   VARCHAR(150),

    PRIMARY KEY (id_param, id_prod)
);


CREATE TABLE product_class_param
(
    id_param INTEGER NOT NULL,
        FOREIGN KEY (id_param)
        REFERENCES parameter(id)
        ON UPDATE CASCADE,
    id_product_class INTEGER NOT NULL,
        FOREIGN KEY (id_product_class)
        REFERENCES product_class(id)
        ON UPDATE CASCADE,
    max_val  DOUBLE PRECISION,
    min_val  DOUBLE PRECISION,
    PRIMARY KEY (id_param, id_product_class)
);

