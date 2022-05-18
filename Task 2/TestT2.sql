--добавим перечисление
select * from insert_enum('Прокатная сталь', 'ПС');

--добавим значения перечислений
select * from insert_enum_val(new_id_enum := 1, new_val := 1, new_position := 1, new_name := 'Сталь горячекатаная', new_short_name := 'СГ');
select * from insert_enum_val(new_id_enum := 1, new_val := 2, new_position := 2, new_name := 'Сталь прокатная угловая', new_short_name := 'СГ');
select * from insert_enum_val(new_id_enum := 1, new_val := 3, new_position := 3, new_name := 'Трубы', new_short_name := 'Т');

select * from change_position_up(2);
select * from change_position_down(4);