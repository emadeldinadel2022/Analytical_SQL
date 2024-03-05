from data_access_layer.dao import OracleDAO

if __name__ == "__main__":
    dao = OracleDAO()
    result = dao.execute_query("SELECT COUNT(*), COUNT(invoice_code) FROM TRANSFORMED_RETAIL")
    if result:
        print(result)
    dao.close_connection()

