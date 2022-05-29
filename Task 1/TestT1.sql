
SELECT * FROM insert_unit_of_measurement('Килограмм', 'кг');
--Автоматическое переназначение родителя
select * from insert_product_class(parent_id := null, name := 'Object 3', short_name := 'O3', measurement_id := 1);
select * from insert_product_class(parent_id := 7, name := 'Object 2', short_name := 'O2', measurement_id := 1);
select * from insert_product_class(parent_id := 8, name := 'Object 1', short_name := 'O1', measurement_id := 1);
select * from insert_product_class(parent_id := 8, name := 'Object 0', short_name := 'O0', measurement_id := 1);

select * from delete_product_class('18');

select * from product_class;
truncate product_class cascade;

select * from product_class_change_parent(class_id := 10, new_parent := 9);

select * from product_class_change_parent(class_id := 7, new_parent := 10);

SELECT *, unit_of_measurement.short_name as ui FROM product_class

                                    LEFT JOIN unit_of_measurement ON
                                    unit_of_measurement.id = product_class.measurement_id;