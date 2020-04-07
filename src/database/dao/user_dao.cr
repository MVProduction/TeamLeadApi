require "./base_dao"

# Для доступа к пользователям
class UserDao < BaseDao
    # Инициализирует таблицу
    def initTable
        # Создаёт таблицу для объявлений пользователя
        db.exec(
            "CREATE TABLE IF NOT EXISTS users
                (
                    user_id INTEGER PRIMARY KEY AUTOINCREMENT,                    
                    email VARCHAR(255)                    
                )
            ")
    end

    # Возвращает пользователя по электронной почте
    def getUserByEmail(email : String)

    end
end