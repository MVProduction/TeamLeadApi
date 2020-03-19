require "orion"
require "sqlite3"
require "json"
require "uuid"
require "mime"
require "./response_codes"
require "./database"

router TeamLeadApi do
    # Возвращает файл по идентификатору
    get "/files/:id" do |context|
        begin
            resourceId = context.request.path_params["id"]
            filePath = "files/#{resourceId}"
            meta = Database.instance.getFileMeta(resourceId)
            if !meta                
                context.response.status = HTTP::Status::NOT_FOUND
                return
            end
        
            context.response.content_type = meta.fileMime

            File.open(filePath, "r") do |f|
                IO.copy(f, context.response)
            end 
        rescue
            context.response.status = HTTP::Status::INTERNAL_SERVER_ERROR
        end
    end

    # Добавляет файл
    put "/files" do |context|
        begin
            name = context.request.query_params["name"]?
            context.response.content_type = "application/json"
            
            if name.nil? || name.empty?
                context.response.puts %({ "code" : #{FILE_NAME_ERROR} })
                return
            end        

            if !context.request.body
                context.response.puts %({ "code" : #{BAD_REQUEST_ERROR} })
                return
            end

            resourceId = UUID.random.to_s
            Dir.mkdir_p("files")
            filePath = "files/#{resourceId}"
            
            # Записывает файл
            File.open(filePath, "w") do |f|
                IO.copy(context.request.body.not_nil!, f)
            end                    
            
            # Записывает метаинформацию
            mime = MIME.from_filename(name) || "application/octet-stream"
            Database.instance.setFileMeta(resourceId, name, mime)

            context.response.puts %({ "code" : #{OK_CODE}, "id" : "#{resourceId}" })
        rescue ex
            context.response.puts %({ "code" : #{INTERNAL_ERROR} })
        end
    end

    # Удаляет файл
    delete "/files/:id" do |context|

    end
end