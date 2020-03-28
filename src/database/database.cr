require "./dao/file_dao"
require "./dao/post_dao"
require "./entity/db_file_meta"

# Для работы с базой API
class Database
    # Экземпляр
    @@instance = Database.new

    # Для доступа к базе
    @context : DB::Database

    # Для доступа к файлам
    getter fileDao : FileDao

    # Для доступа к объявлениям пользователей
    getter postDao : PostDao

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
        
        @postDao.initTable
    end

    # Конструктор
    def initialize
        @context = DB.open "sqlite3://./teamlead.db"
        @fileDao = FileDao.new(@context)
        @postDao = PostDao.new(@context)
        
        initDatabase
    end    
end