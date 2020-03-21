require "./base_dao"
require "../entity/db_post"

# Для доступа к объявлениям пользователя
class PostDao < BaseDao
    # Инициализирует таблицу
    def initTable
        # Создаёт таблицу для объявлений пользователя
        db.exec(
            "CREATE TABLE IF NOT EXISTS posts
                (
                    post_id INTEGER PRIMARY KEY AUTOINCREMENT,                    
                    post_title VARCHAR(255),
                    post_text TEXT NOT NULL,
                    post_date INTEGER DEFAULT 0,
                    user_id INTEGER DEFAULT 0,
                    view_count INTEGER DEFAULT 0,
                    comment_count INTEGER DEFAULT 0,
                    last_comment_id INTEGER DEFAULT 0
                )
            ")
    end

    # Возвращает объявление по идентификатору
    def getPostById(id : Int) : DBPost?
        return db.query_one?("
            SELECT 
                post_id,
                post_title,
                post_text,
                post_date,
                user_id,
                view_count,
                comment_count,
                last_comment_id
            FROM posts
            WHERE post_id=?", id, as: DBPost)        
    end
    
    # Создаёт новый пост и возвращает идентификатор 
    def createPost(
        userId : Int64,
        postTitle : String, 
        postText : String) : Int64        

        date = Time.utc.to_unix
        rs = db.exec("INSERT INTO posts
            (user_id, post_title, post_text, post_date) 
            VALUES(?, ?, ?, ?)", 
            userId, postTitle, postText, date)
        
        rs.last_insert_id
    end
end