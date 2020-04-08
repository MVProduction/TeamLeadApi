require "db"

# Информация пользователя в базе данных
class DBUser
    DB.mapping({
        # Идентификатор пользователя
        user_id: Int64,
        # Электронная почта пользователя
        email: String,
        # Пароль пользователя
        password: String
    })
end