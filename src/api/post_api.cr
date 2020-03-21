require "kemal"
require "../common/common_response_codes"
require "../database/database"

# Сериализует объявление в словарь
def postToDict(post : DBPost)
    {
        code: OK_CODE,
        post: {
            postId: post.post_id,
            postTitle: post.post_title,
            postText: post.post_text,
            postDate: post.post_date,
            userId: post.user_id,
            viewCount: post.view_count,
            commentCount: post.comment_count,
            lastCommentId: post.last_comment_id
        }
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
def postsToResponse(posts : Array(DBPost))
    {
        code: OK_CODE,
        post: posts.map |x| postToDict(x)
    }.to_json
end

# Возвращает объявления по идентификатору
get "/posts/getById" do |env|
    begin
        postId = env.params.url["id"].to_i64?
            
        next { code: BAD_REQUEST_ERROR }.to_json unless postId
        post = Database.instance.postDao.getPostById(postId)
        next { code: NO_DATA_ERROR }.to_json unless post
            
        next postToResponse(post)
    rescue
        next {
            code: INTERNAL_ERROR
        }.to_json
    end
end

# Возвращает срез объявлений с начального идентификатора [id]
# В заданном количестве [count]
# [count] ограничен максимальным количеством объявлений в одном запросе
get "/posts/getRange/:id/:count" do |env|
    begin
        firstId = env.params.url["id"].to_i64?
        count = env.params.url["count"].to_i32?

        if (firstId.nil? || count.nil?)
            next { code: BAD_REQUEST_ERROR }.to_json
        end

        posts = Database.instance.postDao.getPostRange(firstId, count)
        next { code: NO_DATA_ERROR }.to_json unless posts 
        next postsToResponse(posts)
    rescue
        next {
            code: INTERNAL_ERROR
        }.to_json
    end
end

# Сохраняет объявление
put "/posts/create" do |env|
    begin
        postTitle = env.params.json["postTitle"]?.as?(String)
        postText = env.params.json["postText"]?.as?(String)
        userId = env.params.json["userId"]?.as?(Int64)

        if (postTitle.nil? || postText.nil? || userId.nil?)
            next { code: BAD_REQUEST_ERROR }.to_json
        end

        id = Database.instance.postDao.createPost(
            userId.not_nil!, postTitle.not_nil!, postText.not_nil!)

        next {
            postId: id
        }.to_json
    rescue
        next {
            code: INTERNAL_ERROR
        }.to_json
    end
end