require "kemal"
require "sqlite3"
require "json"
require "uuid"
require "mime"
require "../common/common_response_codes"
require "../database/database"
require "./api_helper"

FILE_NAME_ERROR = 2000

# Возвращает файл по идентификатору
get "/files/:id" do |env|
    begin
        resourceId = env.params.url["id"]
        filePath = "files/#{resourceId}"
        meta = Database.instance.fileDao.getFileMeta(resourceId)
        if !meta                
            env.response.status = HTTP::Status::NOT_FOUND
            next
        end
    
        env.response.content_type = meta.fileMime
        
        File.open(filePath, "r") do |f|
            IO.copy(f, env.response)
        end 
    rescue
        env.response.status = HTTP::Status::INTERNAL_SERVER_ERROR
    end
end

# Добавляет файл
put "/files" do |env|
    begin
        name = env.request.query_params["name"]?
        env.response.content_type = "application/json"
        
        if name.nil? || name.empty?
            next getCodeResponse(FILE_NAME_ERROR)
        end        

        if !env.request.body
            next getCodeResponse(BAD_REQUEST_ERROR)
        end

        resourceId = UUID.random.to_s
        Dir.mkdir_p("files")
        filePath = "files/#{resourceId}"
        
        # Записывает файл
        File.open(filePath, "w") do |f|
            IO.copy(env.request.body.not_nil!, f)
        end                    
        
        # Записывает метаинформацию
        mime = MIME.from_filename(name) || "application/octet-stream"
        Database.instance.fileDao.setFileMeta(resourceId, name, mime)

        next {
            code: OK_CODE,
            id: resourceId
        }.to_json        
    rescue ex
        next getCodeResponse(INTERNAL_ERROR)
    end
end

# Удаляет файл
delete "/files/:id" do |env|
end
