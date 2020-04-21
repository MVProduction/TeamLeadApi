require "kemal"
require "./api_helper"
require "../common/common_response_codes"
require "../database/database"

# Сериализует объявление в словарь
def postToDict(post : DBPost)
    {      
        postId: post.post_id,
        postTitle: post.post_title,
        postText:  post.post_text,
        postDate: post.post_date,
        userId: post.user_id,
        viewCount: post.view_count,
        commentCount: post.comment_count,
        lastCommentId: post.last_comment_id
    }
end

# Сериализует объявление в json и добавляет код ответа
def postToResponse(post : DBPost)
    {
        code: OK_CODE,
        post: postToDict(post)
    }.to_json
end

# Сериализует объявления в json и добавляет код ответа
def postsToResponse(posts : Array(DBPost)?, total : Int64? = nil)
    if posts && posts.size > 0
        return {
            code: OK_CODE,
            total: total,
            posts: posts.map { |x| postToDict(x) }
        }.to_json
    else
        return getCodeResponse(NO_DATA_ERROR)
    end    
end

# Возвращает объявления по идентификатору
# Обязательные параметры:
# id - идентификатор объявления
get "/posts/getById/:id" do |env|
    begin
        postId = env.params.url["id"].to_i64?
            
        next getCodeResponse(BAD_REQUEST_ERROR) unless postId
        post = Database.instance.postDao.getPostById(postId)
        next getCodeResponse(NO_DATA_ERROR) unless post
            
        next postToResponse(post)
    rescue        
        next getCodeResponse(INTERNAL_ERROR)
    end
end

# Возвращает срез объявлений 
# Обязательные параметры:
# firstId - начальный идентификатор
# Опциональные параметры:
# tags - тэги по которым запрашиваются объявления
# search - строка поиска. Поиск осуществляется по тексту
# orderby - поле по которому нужно осуществить сортировку
# limit - количество объявление вглубину, ограничено максимальным количеством объявлений в одном запросе
# needCount - признак что нужно вернуть общее количество сообщений
# textLen - длина текста объявления в ответном сообщении
get "/posts/getPosts/:firstId" do |env|
    begin        
        firstId = env.params.url["firstId"].to_i64?        
        
        if firstId.nil?
            next getCodeResponse(BAD_REQUEST_ERROR)
        end
                
        limit = env.params.query["limit"]?.try &.to_i32?

        tags = env.params.query["tags"]?.try &.split(',')
        search = env.params.query["search"]?
        orderby = env.params.query["orderby"]?.try &.split(',')
        needCount = env.params.query["needCount"]? == "true" ? true : false
        textLen = env.params.query["textLen"]?.try &.to_i32?
                
        res = Database.instance.postDao.getPosts(
            firstId, limit, tags, search, orderby, textLen, needCount)        
        next postsToResponse(res[0], res[1])
    rescue e
        p e
        next getCodeResponse(INTERNAL_ERROR)
    end
end

# Сохраняет объявление
put "/posts/create" do |env|
    begin
        postTitle = env.params.json["postTitle"]?.as?(String)
        postText = env.params.json["postText"]?.as?(String)
        userId = env.params.json["userId"]?.as?(Int64)

        if (postTitle.nil? || postText.nil? || userId.nil?)
            next getCodeResponse(BAD_REQUEST_ERROR)
        end

        id = Database.instance.postDao.createPost(
            userId.not_nil!, postTitle.not_nil!, postText.not_nil!)

        next {
            postId: id
        }.to_json
    rescue
        next getCodeResponse(INTERNAL_ERROR)
    end
end