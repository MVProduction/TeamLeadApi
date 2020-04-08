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
end