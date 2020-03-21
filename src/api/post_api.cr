require "kemal"
require "../common/common_response_codes"
require "../database/database"

# Ошибка - объявление отсутствует
POST_NOT_EXISTS_ERROR = 200

# Возвращает пост по идентификатору
get "/posts/:id" do |env|
    postId = env.params.url["id"].to_i64?
        
    next { code: BAD_REQUEST_ERROR }.to_json unless postId
    post = Database.instance.postDao.getPostById(postId)        
    p post
    next { code: POST_NOT_EXISTS_ERROR }.to_json unless post
        
    {
        postId: post.post_id,
        postTitle: post.post_title,
        postText: post.post_text,
        postDate: post.post_date,        
        userId: post.user_id,
        viewCount: post.view_count,        
        commentCount: post.comment_count,
        lastCommentId: post.last_comment_id
    }.to_json
end

# Сохраняет объявление
put "/posts" do |env|
    postTitle = env.params.json["postTitle"].as(String)
    postText = env.params.json["postText"].as(String)
    userId = env.params.json["userId"].as(Int64)
    id = Database.instance.postDao.createPost(userId, postTitle, postText)
    {
        postId: id
    }.to_json
end
