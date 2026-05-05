discard """
  action: "compile"
"""


import ../../src/db_connector/[db_mysql, db_odbc, db_postgres]
import os
from utils import buildDir


block:
  block:
    const dbName = "db.sqlite3"
    var db = db_mysql.open(dbName, "", "", "")
    discard tryInsertId(db, sql"INSERT INTO myTestTbl (name,i,f) VALUES (?,?,?)", "t")

  block:
    const dbName = "db.odbc"
    var db = db_odbc.open(dbName, "", "", "")
    discard tryInsertId(db, sql"INSERT INTO myTestTbl (name,i,f) VALUES (?,?,?)", "t")

  block:
    const dbName = "db.postgres"
    var db = db_postgres.open(dbName, "", "", "")
    discard tryInsertId(db, sql"INSERT INTO myTestTbl (name,i,f) VALUES (?,?,?)", "t")
