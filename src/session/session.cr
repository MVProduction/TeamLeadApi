require "uuid"

# Сессия пользователя
class Session
    # Идентификатор пользователя
    getter userId : Int64

    # Идентификатор сессии
    getter sessionId : String

    # Конструктор
    def initialize(@userId)
        @sessionId = UUID.random().to_s
    end
end