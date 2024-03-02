import cx_Oracle

class OracleDAO:
    _instance = None

    def __new__(cls, *args, **kwargs):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance.__initialized = False
        return cls._instance

    def __init__(self):
        if self.__initialized:
            return
        self.__initialized = True
        self._connection = None
        self._connect_to_oracle()

    def _connect_to_oracle(self):
        try:
            dsn_tns = cx_Oracle.makedsn('localhost', '1521', service_name='xe')
            self._connection = cx_Oracle.connect(user=r'emad_alsql', password='1234', dsn=dsn_tns)
            print("Connect to Oracle DB successfully")
        except cx_Oracle.DatabaseError as e:
            print("Error connecting to Oracle:", e)

    def execute_query(self, query):
        try:
            cursor = self._connection.cursor()
            cursor.execute(query)
            result = cursor.fetchall()
            cursor.close()
            return result
        except cx_Oracle.DatabaseError as e:
            print("Error executing query:", e)
            return None

    def close_connection(self):
        if self._connection:
            self._connection.close()
            self._connection = None

