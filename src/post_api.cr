require "./database"

router TeamLeadApi do
    # Возвращает пост по идентификатору
    get "/posts/:id" do |context|
        context.response.puts "POST"
    end    
end