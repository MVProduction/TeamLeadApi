require "db"

# Объявление пользователя в базе данных
class DBPost
    DB.mapping({
        # Идентификатор объявления
        post_id: Int64,        
        # Заголовок объявления
        post_title: String,
        # Текст объявления
        post_text: String,
        # Дата объявления в секундах от 1970-01-01 00:00:00
        post_date: Int64,
        # Идентификатор пользователя
        user_id: Int64,
        # Количество просмотров
        view_count: Int64,
        # Количество комментариев
        comment_count: Int64,
        # Идентификатор последнего комментария
        last_comment_id: Int64
    })
end