require "./base_dao"
require "../entity/db_post"

# Для доступа к объявлениям пользователя
class PostDao < BaseDao
    # Количество объявлений
    @postCount : Int64 = 0

    # Инициализирует таблицу
    def init
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

            # Получает количество объявлений
            @postCount = db.scalar("
                SELECT count(post_id) FROM posts
            ").as(Float64 | Int64 | String).to_i64
    end

    # Возвращает идентификатор последнего
    def getLastPostId() : Int64
        lastPostId = db.scalar("
            SELECT seq FROM sqlite_sequence WHERE name='posts'"
        ).as(Float64 | Int64 | String).to_i64
        return lastPostId
    end

    # Возвращает количество объявлений
    def getPostCount() : Int64
        @postCount
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

    # Возвращает срез объявлений, разделяя все объявления на страницы
    def getByPage(pageIndex : Int32, pageSize : Int32, textLen : Int32) : Array(DBPost)?
        
    end

    # Возвращает срез объявлений
    def getRange(firstId : Int64, count : Int32, textLen : Int32?) : Array(DBPost)?
        postText = textLen.nil? ? "post_text" : "substr(post_text, 1, #{textLen}) as post_text"

        rs = db.query("
            SELECT 
                post_id,
                post_title,
                #{postText},
                post_date,
                user_id,
                view_count,
                comment_count,
                last_comment_id
            FROM posts
            WHERE post_id<=?
            ORDER BY post_id DESC
            LIMIT ?", firstId, count)
        
        DBPost.from_rs(rs)
    end

    # Возвращает популярные посты в количестве count
    def getPopular(count : Int32, textLen : Int32?) : Array(DBPost)?
        postText = textLen.nil? ? "post_text" : "substr(post_text, 1, #{textLen}) as post_text"

        rs = db.query("
            SELECT 
                post_id,
                post_title,
                #{postText},
                post_date,
                user_id,
                view_count,
                comment_count,
                last_comment_id
            FROM posts            
            ORDER BY view_count, post_id DESC
            LIMIT ?", count)
        
        DBPost.from_rs(rs)
    end

    # Возвращает самые новые объявления в количестве сount
    def getRecent(count : Int32, textLen : Int32?) : Array(DBPost)?
        postText = textLen.nil? ? "post_text" : "substr(post_text, 1, #{textLen}) as post_text"

        rs = db.query("
            SELECT 
                post_id,
                post_title,
                #{postText},
                post_date,
                user_id,
                view_count,
                comment_count,
                last_comment_id
            FROM posts
            ORDER BY post_id DESC
            LIMIT ?", count)
        
        DBPost.from_rs(rs)
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
        
        # Увеличивает счётчик объявлений
        @postCount += 1
        return rs.last_insert_id
    end
end