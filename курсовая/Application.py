from tkinter import *
from tkinter import ttk
from tkinter import messagebox
from functools import partial
import sql_test

# TODO
# Получение списков: продукции, классов, единиц измерения
# Отрабока: удаление родителя, установка родителя, с проверкой на цикл


class Text_window(ttk.Frame):
    def __init__(self, master, DB, *args, left_menu, options, **kwargs):
        super().__init__(master, *args, **kwargs)
        self.DB = DB
        self.options = options
        self.master = master
        self.command = options['command']
        self.text_w = False
        if options['is_input']:

            self.create_input_area()
        else:
            self.execute(self.options['command'])

    def execute(self, formated_command):
        # print(formated_command)
        if (self.text_w):
            self.l_res.pack_forget()
            self.l_res.destroy()
            self.text_w = False

        columns, res = self.DB.execute(formated_command, True)
        if columns == -1:
            messagebox.showinfo("Ошибка", "Проверьте данные\n"+str(res))
            self.text_w = False
            return
        if len(columns) == 0:
            messagebox.showinfo("Успешно", "Ввод успешен")
            self.text_w = False
            return
        if 'SELECT' not in formated_command:
            return
        self.text_w = True

        self.l_res = ttk.Treeview(self.master, show="headings")
        self.l_res['columns'] = columns

        for i in columns:
            self.l_res.column(i, anchor=CENTER)
            self.l_res.heading(i, text=i)

        ysb = Scrollbar(self, orient=VERTICAL, command=self.l_res.yview)
        self.l_res.configure(yscroll=ysb.set)
        for i in res:
            self.l_res.insert("", END, values=i)

        self.l_res.pack(fill=BOTH, expand=1)
    # Для запросов на ввод данных

    def create_input_area(self):
        f = Frame(self)
        self.f = f
        # Можно использовать для получения не всего списка, а определенного элемента через фильтрацию
        if 'insert' in self.options['is_input']:
            q_d = self.options['is_input']['insert']
            ent = q_d['entity']
            fields = q_d['fields']
            self.checkboxes = q_d['checkboxes']
            lab = Label(f, text=q_d['label'])
            lab.pack(side=TOP)
            if self.checkboxes:
                self.check_boxes_list = []
                for box in self.checkboxes:
                    c_f = Frame(f)
                    l = Label(c_f, text=box[1])
                    l.pack(side=TOP)
                    querry_f = ', '.join(box[2])
                    querry = "SELECT {} FROM {}".format(querry_f,
                                                        box[0])
                    h, res = self.DB.execute(querry)
                    self.v = StringVar(c_f, res[0][0])
                    self.check_boxes_list.append(self.v)
                    if (box[1] == 'Выберите новый родительский класс' or
                            box[1] == 'Выберите родительский класс'):
                        Radiobutton(c_f, text='Нет родителя',
                                    variable=self.v, value='0').pack(side=TOP)
                    self.v.set(res[0][0])
                    for row in res:
                        row = list(map(str, row))
                        Radiobutton(c_f,
                                    text=' '.join(list(row)),
                                    variable=self.v,
                                    value=row[0]).pack(side=TOP)
                    c_f.pack(side=TOP)

            self.entries = []
            for (field, field_name) in fields:
                ent_f = Frame(f)
                l = Label(ent_f, text=field_name)
                l.pack(side=TOP)

                self.i = StringVar(ent_f, "")
                self.entries.append(self.i)
                ent = Entry(ent_f, textvariable=self.i)
                ent.pack(side=TOP)
                ent_f.pack(side=TOP)
            if self.checkboxes:
                self.entries += self.check_boxes_list
            action_with_arg = partial(self.run_formated_command, self.command,
                                      self.entries, True)

            Button(f, text='Ввод', command=action_with_arg).pack(side=TOP)

        f.pack(side=LEFT)

    def run_formated_command(self, command, inputs, ent=False):

        self.inputs = inputs[:]
        f_command = command.format(*list(
            map(lambda x: "'" + x.get() + "'"
                if x.get() != '0' else 'NULL', self.inputs)))
        print(f_command)

        self.execute(f_command)


class Types(ttk.Frame):
    def __init__(self, master, *args, DB, queries, **kwargs):

        super().__init__(master, *args, **kwargs)
        self.DB = DB
        self.is_w = False
        self.master = master
        self.mod_f = Frame(master)

        l_f = Frame(self, background='red')

        buttons = []
        for button in queries.keys():
            opt = queries[button]
            action_with_arg = partial(self.create_request_section, opt)
            r = Button(l_f, text=button, command=action_with_arg)
            r.pack(side=TOP, fill=BOTH, expand=1)

        l_f.pack(side=LEFT, fill=BOTH)

    def create_request_section(self, options):
        if self.is_w:
            self.container.pack_forget()
            self.container.destroy()
        self.container = Frame(self.master)
        self.canvas = Canvas(self.container)
        scrollbar = Scrollbar(self.container, orient="vertical",
                              command=self.canvas.yview)

        self.w = Text_window(self.canvas,
                             DB=self.DB,
                             left_menu=self,
                             options=options)
        self.canvas.bind_all("<MouseWheel>",
                             lambda e: self.canvas.yview_scroll(
                                 int(-1*(e.delta/120)), "units")
                             )
        # При любомизменении рассчитываем скролбар
        self.w.bind("<Configure>",
                    lambda e: self.canvas.configure(
                        scrollregion=self.canvas.bbox("all")
                    )
                    )
        self.container.pack(fill=BOTH, expand=1, side=RIGHT)
        self.canvas.create_window((0, 0), window=self.w, anchor="nw")
        self.canvas.configure(yscrollcommand=scrollbar.set)
        self.canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side=RIGHT, fill=Y)
        # self.w.pack(fill=BOTH, side=LEFT)
        self.canvas.configure(scrollregion=self.canvas.bbox("all"))
        self.is_w = True


class Main_application(ttk.Frame):
    def __init__(self, master, *args, **kwargs):

        super().__init__(master, *args, **kwargs)

        self.master = master
        self.start('admin')

    def eneter_db(self, login, password):
        data = {
            'host': "127.0.0.1",
            'user': login,
            'password': password,
            'database': "mispris"
        }
        return sql_test.DB(data)

    def start(self, mode):
        # self.chose_f.pack_forget()
        # self.chose_f.destroy()
        if mode == 'admin':
            login = 'postgres'
            password = 'admin'
            # Важен порядок в запросе сначала указываем обычные поля, после чекбоксы
            queries = {
                "Список классов продуктов": {
                    'command': """SELECT product_class.*, unit_of_measurement.short_name AS um FROM product_class
                    
                                    LEFT JOIN unit_of_measurement ON 
                                    unit_of_measurement.id = product_class.measurement_id;""",
                    'is_input': False
                },
                "Список продуктов": {
                    'command':
                    """SELECT product.*, product_class.name as p_c_name  FROM product
                                    LEFT JOIN product_class ON
                                    product_class.id = product.class_id;""",
                    'is_input': False
                },
                "Список eдиниц измерения": {
                    'command': "SELECT * FROM unit_of_measurement;",
                    'is_input': False
                },

                "Найти родителя": {
                    'command': """SELECT * FROM product_class_find_parent({});""",
                    'is_input':  {
                        'insert': {
                            'label':
                            'Введите данные е.и',
                            'entity':
                                ['unit_of_measurement'],
                            'fields': [],
                            'checkboxes': [('product_class', 'Выберите класс',
                                            ['id, name'])],
                        }
                    }
                },
                "Найти потомка": {
                    'command': """SELECT * FROM product_class_find_children({})""",
                    'is_input':  {
                        'insert': {
                            'label':
                            'Введите данные е.и',
                            'entity':
                                ['unit_of_measurement'],
                            'fields': [],
                            'checkboxes': [('product_class', 'Выберите класс',
                                            ['id, name'])],
                        }
                    }
                },
                'Добавить единицу измерения': {
                    'command':
                    """SELECT * FROM insert_unit_of_measurement({}, {});""",
                    'is_input': {
                        'insert': {
                            'label':
                            'Введите данные е.и',
                            'entity':
                                ['unit_of_measurement'],
                            'fields': [['name', 'название'],
                                       ['short_name', 'название кратко'],
                                       ],
                            'checkboxes': [],
                        }
                    }
                },

                'Добавить класс продукта': {
                    'command':  """
                    SELECT * FROM insert_product_class(name =>{}, short_name=>{}, measurement_id=>{}, parent_id=>{});""",

                    'is_input': {
                        'insert': {
                            'label':
                            'Выберите единицу измерения',
                            'entity': ['product_class'],
                            'fields': [['name', 'название'],
                                       ['short_name', 'название кратко'],
                                       ],
                            'checkboxes': [
                                ('unit_of_measurement',
                                 'Единица измерения', ['id', 'short_name']),
                                ('product_class', 'Выберите родительский класс',
                                    ['id, name'])
                            ],
                        }
                    }
                },
                'Добавить продукт': {
                    'command':  """
                        SELECT * FROM insert_product(name=>{}, class_id=>{})""",
                        'is_input': {
                            'insert': {
                                'label':
                                'Выберите класс продукта',
                                'entity': ['product'],
                                'fields': [['name', 'название'],
                                           ],
                                'checkboxes':
                                [('product_class', 'Класс продукта',
                                 ['id, short_name'])],
                            }
                        }
                },
                'Изменить единицу измерения': {
                    'command':  """
                        SELECT * FROM alter_unit_of_measurement(alt_name=>{}, alt_short_name =>{}, alt_id=>{});
                       
                        """,
                    'is_input': {
                        'insert': {
                            'label':
                            'Выберите единицу измерения и задайте ее новые параметры',
                            'entity': ['unit_of_measurement'],
                            'fields': [['name', 'название'],
                                       ['short_name', 'крпткое название']],
                            'checkboxes':
                            [('unit_of_measurement', 'Единицы зимерения',
                                ['id, name'])],

                        }
                    }
                },
                'Изменить класс продукта': {
                    'command':  """
                       SELECT * FROM alter_product_class(
                           alt_name =>{}, 
                           alt_short_name=>{},
                           alt_id=>{},
                           alt_measurement_id=>{},
                           alt_parent_id=>{});
                        """,
                    'is_input': {
                        'insert': {
                            'label':
                            'Выберите класс продукта и задайте новые параметры',
                            'entity': ['product_class'],
                            'fields': [['name', 'название'],
                                       ['short_name', 'краткое название']],
                            'checkboxes':
                            [
                                ('product_class', 'Выбор класса для изменения',
                                 ['id, name']),
                                ('unit_of_measurement', 'Единица измерения',
                                 ['id, short_name']),
                                ('product_class', 'Выберите новый родительский класс',
                                 ['id, name']),
                            ],

                        }
                    }
                },

                'Изменить  товар': {
                    'command':  """
                        SELECT * FROM alter_product(
                            alt_name => {},
                            alt_id => {},
                            alt_class_id => {}
                        );
                        """,
                    'is_input': {
                        'insert': {
                            'label':
                            'Выберите продукт',
                            'entity': ['product'],
                            'fields': [['name', 'название'],
                                       ],
                            'checkboxes':
                            [
                                ('product', 'Продукт который будет изменен',
                                    ['id, name']),
                                ('product_class', 'Класс продукта',
                                 ['id, short_name']),
                            ],

                        }
                    }
                },
                'Удалить единицу измерения': {
                    'command':  """
                        SELECT * FROM delete_unit_of_measurement({});
                        """,
                    'is_input': {
                        'insert': {
                            'label':
                            'Выберите единицу измерения',
                            'entity': ['unit_of_measurement'],
                            'fields': [],
                            'checkboxes':
                            [('unit_of_measurement', 'Класс продукта',
                                ['id, name'])],

                        }
                    }
                },

                'Удалить класс продукта': {
                    'command':  """
                         SELECT * FROM delete_product_class({});
                        """,
                    'is_input': {
                        'insert': {
                            'label':
                            'Выберите класс товара',
                            'entity': ['product_class'],
                            'fields': [],
                            'checkboxes':
                            [('product_class', 'Классы товара',
                                ['id, name'])],

                        }
                    }
                },

                'Удалить продукт': {
                    'command':  """
                        SELECT * FROM delete_product({});
;
                        """,
                    'is_input': {
                        'insert': {
                            'label':
                            'Выберите  товар',
                            'entity': ['product'],
                            'fields': [],
                            'checkboxes':
                            [('product', 'Товары',
                                ['id, name'])],

                        }
                    }
                },
            }

        db = self.eneter_db(login, password)
        if not db.is_error:
            f = Types(self, DB=db, queries=queries)
            f.pack(fill=BOTH, side=LEFT)


root = Tk()
root.title("Сталь")

root.minsize(800, 400)
app = Main_application(root)
app.pack(fill=BOTH, expand=1)
root.mainloop()
