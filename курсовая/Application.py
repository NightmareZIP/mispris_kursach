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
            'database': "misp2"
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
                    'command': """SELECT class_izdeliy.*, EI.short_name_EI AS um FROM class_izdeliy
                    
                                    LEFT JOIN EI ON 
                                    EI.ID_EI = class_izdeliy.EI_ID;""",
                    'is_input': False
                },
                "Список продуктов": {
                    'command':
                    """SELECT product.*, class_izdeliy.name as p_c_name  FROM product
                                    LEFT JOIN class_izdeliy ON
                                    class_izdeliy.ID_class = product.class_ID;""",
                    'is_input': False
                },
                "Список eдиниц измерения": {
                    'command': "SELECT * FROM EI;",
                    'is_input': False
                },



                "Вывод спецификации": {
                    'command': """SELECT * FROM showspec({});""",
                    'is_input':  {
                        'insert': {
                            'label':
                            'Введите данные продукта',
                            'entity':
                                ['unit_of_measurement'],
                            'fields': [],
                            'checkboxes': [('product', 'Выберите продукт',
                                            ['ID_prod, name_proD'])],
                        }
                    }
                },
                "Найти количество необходимых элементов": {
                    'command': """SELECT * FROM countClassAmount(amount=>{}, id_prod=>{})""",
                    'is_input':  {
                        'insert': {
                            'label':
                            'Введите данные продукта и количества',
                            'entity':
                                ['unit_of_measurement'],
                            'fields': [['amount', 'количество']],
                            'checkboxes': [('product', 'Выберите продукт',
                                            ['ID_prod, name_proD'])],
                        }
                    }
                },
                'Добавить единицу измерения': {
                    'command':
                    """SELECT * FROM add_ei({}, {});""",
                    'is_input': {
                        'insert': {
                            'label':
                            'Введите данные е.и',
                            'entity':
                                ['EI'],
                            'fields': [['short_name_EI', 'название кратко'],
                                       ['name_EI', 'название'],

                                       ],
                            'checkboxes': [],
                        }
                    }
                },

                'Добавить класс продукта': {
                    'command':  """
                    SELECT * FROM add_class(full_name =>{}, class_short_name=>{}, ei=>{}, parent=>{});""",

                    'is_input': {
                        'insert': {
                            'label':
                            'Выберите класс продукта',
                            'entity': ['class_izdeliy'],
                            'fields': [['full_name', 'название'],
                                       ['class_short_name', 'название кратко'],
                                       ],
                            'checkboxes': [
                                ('EI',
                                 'Единица измерения', ['ID_EI', 'short_name_EI']),
                                ('class_izdeliy', 'Выберите родительский класс',
                                    ['ID_class, name'])
                            ],
                        }
                    }
                },
                'Добавить продукт': {
                    'command':  """
                        SELECT * FROM add_prod(full_prod_name=>{},short_prod_name=>{}, id_class=>{})""",
                        'is_input': {
                            'insert': {
                                'label':
                                'Выберите продукт',
                                'entity': ['product'],
                                'fields': [['name_proD', 'название'],
                                           ['short_name_proD', 'название кратко']
                                           ],
                                'checkboxes':
                                [('class_izdeliy', 'Класс продукта',
                                 ['ID_class, short_name'])],
                            }
                        }
                },
            }

        db = self.eneter_db(login, password)
        if not db.is_error:
            f = Types(self, DB=db, queries=queries)
            f.pack(fill=BOTH, side=LEFT)


root = Tk()
root.title("Кровати")

root.minsize(800, 400)
app = Main_application(root)
app.pack(fill=BOTH, expand=1)
root.mainloop()
