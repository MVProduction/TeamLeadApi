require "../common_constants"

# Заявка на регистрацию
class RegisterTicket
    # Время жизни заявки в секундах
    LINK_TIME_LIVE_SECONDS = 60 * 5

    # Идентификатор заявки
    getter ticketId : String    

    # Дата регистрации
    getter expireDate : Time

    # Логин/почта пользователя
    getter login : String

    # Пароль пользователя
    getter password : String

    # Конструктор
    def initialize(@login, @password)
        @ticketId = UUID.random().to_s
        @expireDate = Time.utc + Time::Span.new(seconds: LINK_TIME_LIVE_SECONDS)
    end
end