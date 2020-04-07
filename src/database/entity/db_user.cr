require "db"

# Информация пользователя в базе данных
class DBPost
    DB.mapping({
        # Идентификатор пользователя
        user_id: Int64,
        # Электронная почта пользователя
        email: String
    })
end