# -*- coding: utf-8 -*-
class Manager
  def initialize(root_path,options)
    default_options = {
      "test_mysqld"   => {
        "mysql"           => '/usr/sbin/mysqld',
        "mysql_install_db"=> '/usr/bin/mysql_install_db',
        "log"             => root_path+"/log/test-mysql.log",
        "log_append"      => true
      },
      "mysql"       => {
        "init_sql"        => root_path+'/sql/init.sql',
        "socket"          => '/tmp/mysql.sock'
      }
    }

    config = root_path+"/config/test-mysql.yml"
    options = YAML.load_file(config)
    options = default_options.deep_merge(options)

    @mysql_pid_file   = root_path+"/tmp/mysql_pid-file"
    @my_cnf           = root_path+"/tmp/my.cnf"
    @datadir          = root_path+"/tmp/var"

    @mysql            = options["test_mysqld"]["mysql"]
    @mysqld           = options["test_mysqld"]["mysqld"]
    @mysql_install_db = options["test_mysqld"]["mysql_install_db"]
    @log              = options["test_mysqld"]["log"]
    @init_file        = options["mysql"]["init_sql"]
    @socket_path      = options["mysql"]["socket"]
    @log_mode         = options["test_mysqld"]["log_append"] ? 'a' : 'w'

    log_path = File.dirname(@log)
    FileUtils.mkdir_p(log_path)
  end

  def start
    return_code = 0
    if File.exists? @mysql_pid_file
      return -1
    end

    pid = spawn @mysqld + " --defaults-file=" + @my_cnf + " --init-file=" + @init_file + " -u root 2>&1", {
      :out => [@log, @log_mode]
    }
    return return_code
  end

  def stop
    return_code = -1
    if File.exists? @mysql_pid_file
      open @mysql_pid_file do |f|
        mysql_pid = f.gets
        Process.kill :QUIT, mysql_pid.to_i
        return_code = 0
      end
    else
      return_code = -1
    end
    return return_code
  end

  def reload
    spawn @mysql + " -u root --socket=" + @socket_path + " < " + @init_file , {
      :out => [@log, @log_mode]
    }
  end

  def waitShutdown(sec)
    sec.times {
      break unless File.exists? @mysql_pid_file
      sleep 1
    }
  end

  def setup
    tmp_dir = File::dirname(@my_cnf)
    FileUtils::mkdir_p(tmp_dir) unless File::directory?(tmp_dir)
    open @my_cnf, "w+" do |f|
      f.puts <<"EOS"
[client]
  default-character-set = utf8

[mysqld]
  skip-networking
  pid-file = #{@mysql_pid_file}
  socket = #{@socket_path}
  datadir = #{@datadir}
  skip-character-set-client-handshake
  character-set-server = utf8
  collation-server = utf8_general_ci
  init-connect = SET NAMES utf8

EOS
    end
    mysql_install_db_dir = File.expand_path('../..', @mysql_install_db)
    system @mysql_install_db + " --basedir=" + mysql_install_db_dir + " --datadir=" + @datadir + " --defaults-file=" + @my_cnf + " 2>&1", {:out => [@log, @log_mode]}
  end
end
