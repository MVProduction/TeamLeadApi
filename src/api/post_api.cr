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

# Возвращает объявления постранично и общее количество страниц
# Обязательные параметры
# page - номер страницы
# postsInPage - количество объявлений в странице
# Опциональные параметры:
# tags - тэги по которым запрашиваются объявления
# orderby - поле по которому нужно осуществить сортировку
# textLen - длина текста объявления в ответном сообщении
get "/posts/getPostsByPage/:page/:postsInPage" do |env|
    begin
        page = env.params.url["page"]?.try &.to_i32?
        postsInPage = env.params.url["postsInPage"]?.try &.to_i32?
        
        if page.nil? || page == 0
            page = 1
        end        

        if postsInPage.nil?
            next getCodeResponse(BAD_REQUEST_ERROR)
        end
        
        tags = env.params.query["tags"]?.try &.split(',')
        orderby = env.params.query["orderby"]?.try &.split(',')
        textLen = env.params.query["textLen"]?.try &.to_i32?
        
        postCount = Database.instance.postDao.getPostsCount(tags)
        pageCount = (postCount / postsInPage).to_i32

        if page > pageCount
            page = pageCount
        end
        
        offset = ((page - 1) * postsInPage).to_i64
        if offset < 0
            offset = 0_i64
        end

        posts = Database.instance.postDao.getPostsByOffset(offset, postsInPage, tags, orderby, textLen)
        
        next {
            code: OK_CODE,
            posts: posts.map { |x| postToDict(x) },
            pageCount: pageCount
        }.to_json
    rescue        
        next getCodeResponse(INTERNAL_ERROR)
    end
end

# Возвращает срез объявлений используя курсор(начальный идентификатор объявления)
# Опциональные параметры:
# firstId - начальный идентификатор
# tags - тэги по которым запрашиваются объявления
# search - строка поиска. Поиск осуществляется по тексту
# orderby - поле по которому нужно осуществить сортировку
# limit - количество объявление вглубину, ограничено максимальным количеством объявлений в одном запросе
# textLen - длина текста объявления в ответном сообщении
get "/posts/getPostsByCursor" do |env|
    begin
        p env.params.query
        firstId = env.params.query["firstId"]?.try &.to_i64?
        limit = env.params.query["limit"]?.try &.to_i32?
        tags = env.params.query["tags"]?.try &.split(',')
        orderby = env.params.query["orderby"]?.try &.split(',')
        textLen = env.params.query["textLen"]?.try &.to_i32?

        res = Database.instance.postDao.getPostsByCursor(
            firstId, limit, tags, orderby, textLen)
        next postsToResponse(res, nil)
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