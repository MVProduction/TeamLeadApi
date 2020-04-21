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
def postsToResponse(posts : Array(DBPost)?)
    if posts && posts.size > 0
        return {
            code: OK_CODE,
            posts: posts.map { |x| postToDict(x) }
        }.to_json
    else
        return getCodeResponse(NO_DATA_ERROR)
    end    
end

# Возвращает количество объявлений
get "/posts/getPostCount" do |env|
    begin
        postCount = Database.instance.postDao.getPostCount
        next {
            code: OK_CODE,
            postCount: postCount
        }.to_json
    rescue
        next getCodeResponse(INTERNAL_ERROR)
    end
end

# Возвращает последний идентификатор объявления
get "/posts/getLastPostId" do |env|
    begin
        lastPostId = Database.instance.postDao.getLastPostId

        next {
            code: OK_CODE,
            lastPostId: lastPostId
        }.to_json
    rescue
        next getCodeResponse(INTERNAL_ERROR)
    end
end

# Возвращает объявления по идентификатору
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
# count - количество объявление вглубину, ограничено максимальным количеством объявлений в одном запросе
# Опциональные параметры:
# textLen - длина текста объявления в ответном сообщении
get "/posts/getRange/:firstId/:count" do |env|
    begin        
        firstId = env.params.url["firstId"].to_i64?
        count = env.params.url["count"].to_i32?
        
        if (firstId.nil? || count.nil?)
            next getCodeResponse(BAD_REQUEST_ERROR)
        end

        textLen = env.params.query["textLen"]?.try &.to_i32?
                
        posts = Database.instance.postDao.getRange(firstId, count, textLen)        
        next postsToResponse(posts)
    rescue e
        p e
        next getCodeResponse(INTERNAL_ERROR)
    end
end

# Возвращает объявления разбивая их на страницы
# Обязательные параметры
# pageIndex - номер страницы
# pageSize - размер страницы
# Опциональные параметры:
# textLen - длина текста объявления в ответном сообщении
get "/posts/getByPage/:pageIndex/:pageSize" do |env|
    begin        
        pageIndex = env.params.url["pageIndex"].to_i64?
        pageSize = env.params.url["pageSize"].to_i32?
        
        if (pageIndex.nil? || pageSize.nil?)
            next getCodeResponse(BAD_REQUEST_ERROR)
        end

        textLen = env.params.query["textLen"]?.try &.to_i32?
                
        posts = Database.instance.postDao.getByPage(pageIndex, pageSize, textLen)
        next postsToResponse(posts)
    rescue e
        p e
        next getCodeResponse(INTERNAL_ERROR)
    end
end

# Возвращает самые популярные объявления
# count - максимальное количество, ограничено максимальным количеством
# Опциональные параметры:
# textLen - длина текста объявления в ответном сообщении
get "/posts/getPopular/:count" do |env|
    begin
        count = env.params.url["count"].to_i32?
        
        next getCodeResponse(BAD_REQUEST_ERROR) unless count

        textLen = env.params.query["textLen"]?.try &.to_i32?

        posts = Database.instance.postDao.getPopular(count, textLen)        
        next postsToResponse(posts)
    rescue
        next getCodeResponse(INTERNAL_ERROR)
    end
end

# Возвращает самые новые объявления
# count - максимальное количество, ограничено максимальным количеством
get "/posts/getRecent/:count" do |env|
    begin
        count = env.params.url["count"].to_i32?        
        next getCodeResponse(BAD_REQUEST_ERROR) unless count

        textLen = env.params.query["textLen"]?.try &.to_i32?

        posts = Database.instance.postDao.getRecent(count, textLen)        
        next postsToResponse(posts)
    rescue
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