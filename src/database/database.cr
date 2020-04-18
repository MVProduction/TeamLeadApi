require "./dao/file_dao"
require "./dao/post_dao"
require "./dao/user_dao"
require "./entity/db_file_meta"

# Для работы с базой API
class Database
    # Экземпляр
    @@instance = Database.new

    # Для доступа к базе
    @context : DB::Database

    # Для доступа к файлам
    getter fileDao : FileDao

    # Для работы с объявлениям/проектами пользователей
    getter postDao : PostDao

    # Для работы с пользователями
    getter userDao : UserDao

    # Возвращает экземпляр
    def self.instance
        @@instance
    end

    # Инициализирует базу
    private def initDatabase
        # Создаёт таблицу для файлов
        @context.exec(
            "CREATE TABLE IF NOT EXISTS files
                (
                    file_id string,
                    file_name varchar(255),
                    file_mime varchar(255)
                )
            ") 
        
        @fileDao.init
        @postDao.init
        @userDao.init
    end

    # Конструктор
    def initialize
        @context = DB.open "sqlite3://./teamlead.db"
        @fileDao = FileDao.new(@context)
        @postDao = PostDao.new(@context)
        @userDao = UserDao.new(@context)
        
        initDatabase
    end    
end