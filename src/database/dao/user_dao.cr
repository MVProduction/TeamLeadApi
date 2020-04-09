require "./base_dao"
require "../entity/db_user"

# Для доступа к пользователям
class UserDao < BaseDao
    # Инициализирует таблицу
    def initTable
        # Создаёт таблицу для объявлений пользователя
        db.exec(
            "CREATE TABLE IF NOT EXISTS users
                (
                    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
                    email VARCHAR(255),
                    password VARCHAR(255)
                )
            ")
        
        # Создаёт индекс по email
        db.exec("
            CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email 
            ON users (email);
        ")
    end

    # Возвращает пользователя по электронной почте
    def getUserByEmail(email : String)
        return db.query_one?("
            SELECT 
                user_id,
                email,
                password                
            FROM users
            WHERE email=?", email, as: DBUser)
    end

    # Создаёт нового пользователя
    # Возвращает идентификатор пользователя
    def createUser(login : String, password : String) : Int64
        rs = db.exec("
            INSERT INTO users(email,password)
            VALUES(?,?)
        ")

        return rs.last_insert_id
    end
end