-- DROP DATABASE IF EXISTS MISPRIS;
-- CREATE DATABASE MISPRIS;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS product_class CASCADE;
DROP TABLE IF EXISTS unit_of_measurement CASCADE ;
CREATE TABLE unit_of_measurement (
    id INT GENERATED ALWAYS AS IDENTITY,
    PRIMARY KEY (id),
    name VARCHAR(30),
    short_name VARCHAR(20)
);
CREATE TABLE product_class (
    id INT GENERATED ALWAYS AS IDENTITY,
    PRIMARY KEY (id),
    parent_id INT DEFAULT NULL,
    name VARCHAR(30),
    short_name VARCHAR(20),
    measurement_id INT NOT NULL ,
    FOREIGN KEY (measurement_id)
        REFERENCES unit_of_measurement(id)
        ON DELETE SET NULL,
    FOREIGN KEY (parent_id)
        REFERENCES product_class(id)
        ON DELETE SET NULL
);
CREATE TABLE product (
    id INT GENERATED ALWAYS AS IDENTITY,
    PRIMARY KEY (id),
    class_id INT,
    name VARCHAR(250),
    --designation VARCHAR(250), --обозначение
    FOREIGN KEY (class_id)
        REFERENCES product_class(id)
        ON DELETE SET NULL
);