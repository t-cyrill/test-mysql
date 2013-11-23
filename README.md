test-mysql
----

test-mysql.rbはテスト用mysqlプロセスを管理するスクリプトです。
Ruby > 1.9.3 が必要です。

## usage
### test-mysql
シェルの中で起動する。Ctrl-Cで終了できる。

### test-mysql start
デーモンとして起動する。stopで終了できる。

### test-mysql stop
デーモンとして起動しているmysqldを終了する。

### test-mysql setup
test_mysqlの初期セットアップを行う。
startを実行する前にDBを初期化する必要があります。
setupはDBの初期化を自動的に行います。
またconfig/test_mysql.ymlに従ってmy.cnfを自動的に生成します。

## configuration
``` config/test_mysql.yml
default configuration =>
test_mysqld:
  # mysqldへのパス
  mysql             : "/usr/sbin/mysqld"
  # mysql_install_dbへのパス
  mysql_install_db  : "/usr/bin/mysql_install_db"

  mysql:
    # mysqlのソケットファイルの位置(setupで作成されるmy.cnf)
    socket            : "/tmp/mysqld.sock"
    # 初期化に使うsqlが書かれたファイルのパス
    # init_sql          : ""
```
