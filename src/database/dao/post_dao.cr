require "./base_dao"
require "../entity/db_post"

# Для доступа к объявлениям пользователя
class PostDao < BaseDao    
    # Количество ответов по умолчанию
    DEFAULT_POST_LIMIT = 20

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
                
        return rs.last_insert_id
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

    # Возвращает объявления  с заданной фильрацией
    # postId - идентификатор объявления с которого начинается поиск
    # limit - количество возвращаемых объявлений
    # tags - тэги по которым нужно вернуть объявления
    # search - строка поиска
    # textLen - количество символов в тексте объявления
    # orderby - название поля по которому сортируется результат
    # needCount - признак что нужно вернуть общее количество сообщений
    # Возвращает массив объявлений и общее количество сообщений
    def getPosts(                        
            postId : Int64? = nil,
            limit : Int32? = DEFAULT_POST_LIMIT,
            tags : Array(String)? = nil,
            search : String? = nil,
            orderby : Array(String)? = nil,
            textLen : Int32? = nil,
            needCount : Bool? = nil
        ) : Tuple(Array(DBPost)?, Int64?)
        
        postText = textLen.nil? ? "post_text" : "substr(post_text, 1, #{textLen}) as post_text"

        query = "
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
        "

        conditions = "WHERE "
        if postId
            conditions += "post_id <= #{postId}"
        end

        if orderby
            order = orderby.join(',')
            # TODO настройка восходящего и нисходящего
            conditions += " ORDER BY #{order} DESC"
        end

        if limit
            conditions += " LIMIT #{limit}"
        end        

        postQuery = query + conditions
        rs = db.query(postQuery)
        posts = DBPost.from_rs(rs)

        # Считает полное количество сообщений
        count : Int64? 
        if needCount
            cquery = "SELECT count(post_id) FROM posts"
            count = db.scalar(cquery).as(Float64 | Int64 | String).to_i64
        end

        return { posts, count }
    end
end