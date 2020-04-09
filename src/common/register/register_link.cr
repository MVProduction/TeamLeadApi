require "../common_constants"

# Ссылка на регистрацию
class RegisterLink
    # Время жизни ссылки
    LINK_TIME_LIVE_SECONDS = 60 * 5

    # Идентификатор ссылки
    getter linkId : String

    # URL ссылки
    getter linkUrl : String

    # Дата регистрации
    getter expireDate : Time

    # Конструктор
    def initialize()
        @linkId = UUID.random().to_s
        @linkUrl = "http://#{HOST_NAME}/user/register_confirm/#{linkId}"
        @expireDate = Time.utc + Time::Span.new(seconds: LINK_TIME_LIVE_SECONDS)
    end
end