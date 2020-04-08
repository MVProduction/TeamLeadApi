require "uuid"

# Сессия пользователя
class Session
    # Время жизни сессии в секундах
    SESSION_TIME_LIVE_SECONDS = 10

    # Идентификатор пользователя
    getter userId : Int64

    # Идентификатор сессии
    getter sessionId : String

    # Время истечения сессии
    getter expireDate : Time

    # Конструктор
    def initialize(@userId)
        @sessionId = UUID.random().to_s
        @expireDate = Time.utc
        makeLive
    end

    # Продлевает жизнь сессии
    def makeLive
        @expireDate = Time.utc + Time::Span.new(seconds: SESSION_TIME_LIVE_SECONDS)
    end
end