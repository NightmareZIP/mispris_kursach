import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT


class DB:
    def __init__(self, data):
        self.data = data
        self.is_error = False
        try:
            self.mydb = psycopg2.connect(
                **self.data

            )
            self.mydb.close()

        except:
            self.is_error = True
            return "Connetction error"

    def execute(self, command, proc=False):
        try:
            self.mydb = psycopg2.connect(
                **self.data

            )
            self.mycursor = self.mydb.cursor()

        except:
            self.is_error = True
            return "Connetction error"
        check = ('INSERT' in command) or (
            'UPDATE' in command) or ('DELETE' in command)
        try:
            self.mycursor.execute(command)
            self.mydb.commit()

            if check:
                myresult = []
            else:
                myresult = self.mycursor.fetchall()

            #headers = self.mycursor.column_names

        except Exception as e:
            print("Something else went wrong\n", e)
            if check:
                self.mydb.rollback()

            return -1, e
        else:
            self.mydb.close()
            if not check:
                colnames = [desc[0] for desc in self.mycursor.description]
            else:
                colnames = []
            return colnames, myresult
