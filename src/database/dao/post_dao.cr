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

    # Возвращает количество объявлений по заданному фильтру
    def getPostsCount(
            tags : Array(String)? = nil            
        ) : Int64

        query = "
            SELECT 
                count(post_id)            
            FROM posts 
        "

        # Считает полное количество сообщений
        # TODO: оптимизация подсчёта количества
        # count : Int64?        
        count = db.scalar(query).as(Float64 | Int64 | String).to_i64
        return count
    end

    # Возвращает объявления с заданной позиции
    # offset - сдвиг от начала
    # limit - количество возвращаемых объявлений
    # tags - тэги по которым нужно вернуть объявления
    # textLen - количество символов в тексте объявления
    # orderby - название поля по которому сортируется результат  
    def getPostsByOffset(
            offset : Int64? = nil,
            limit : Int32? = nil,
            tags : Array(String)? = nil,
            orderby : Array(String)? = nil,
            textLen : Int32? = nil
        ) : Array(DBPost)

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
        finalLimit = limit || DEFAULT_POST_LIMIT

        conditions = ""        
        if orderby
            order = orderby.join(',')
            # TODO настройка восходящего и нисходящего
            conditions += " ORDER BY #{order} DESC"
        else
            conditions += " ORDER BY post_id DESC"
        end

        if offset
            conditions += " LIMIT #{offset},#{finalLimit}"
        else
            conditions += " LIMIT #{finalLimit}"
        end

        # TODO: убрать gsub
        postQuery = (query + conditions).gsub("\n", "")
        p postQuery

        rs = db.query(postQuery)
        posts = DBPost.from_rs(rs)        

        return posts
    end

    # Возвращает объявления с заданной фильтрацией используя курсор(начальный идентификатор объявления)
    # postId - идентификатор объявления с которого начинается поиск
    # limit - количество возвращаемых объявлений
    # tags - тэги по которым нужно вернуть объявления
    # textLen - количество символов в тексте объявления
    # orderby - название поля по которому сортируется результат    
    def getPostsByCursor(
            postId : Int64? = nil,
            limit : Int32? = nil,
            tags : Array(String)? = nil,
            orderby : Array(String)? = nil,
            textLen : Int32? = nil            
        ) : Array(DBPost)
        
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
        
        conditions = ""
        if postId            
            conditions += "post_id <= #{postId}"
        end

        if !conditions.empty?
            conditions = " WHERE " + conditions
        end

        if orderby
            order = orderby.join(',')
            # TODO настройка восходящего и нисходящего
            conditions += " ORDER BY #{order} DESC"
        end

        limit ||= DEFAULT_POST_LIMIT
        conditions += " LIMIT #{limit}"

        postQuery = query + conditions
        p postQuery

        rs = db.query(postQuery)
        posts = DBPost.from_rs(rs)        
        
        return posts
    end

    # Возвращает объявления по строке поиска
    # search - строка поиска
    # firstId - идентификатор объявления от которого нужно производить поиск
    # limit - количество возвращаемых сообщений    
    def getPostsBySearch(
        search : String,
        firstId : Int64? = nil,
        limit : Int32? = nil)

    end
end