require "uuid"

require "./register_link"

# Менеджер регистрации пользователя
# Управляет ссылками на регистрацию
class RegisterLinkManager
    # Время проверки в секундах
    CHECK_TIME_SECONDS = 60 * 5

    # Экземпляр
    @@instance = RegisterLinkManager.new

    # Ссылки
    @links = Hash(String, RegisterLink).new

    # Возвращает экземпляр
    def self.instance
        @@instance
    end

    # Конструктор
    def initialize
        spawn do
            loop do
                sleep(CHECK_TIME_SECONDS)

                now = Time.utc

                @links.delete_if { |k, link|
                    res = link.expireDate < now
                    p "Register link #{link.linkId} expired" if res
                    res
                }
            end
        end
    end

    # Создаёт ссылку
    def createLink() : RegisterLink                
        link = RegisterLink.new
        @links[link.linkId] = link
        return link
    end
end