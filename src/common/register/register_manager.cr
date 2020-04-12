require "uuid"

require "./register_ticket"

# Менеджер регистрации пользователя
# Управляет заявками на регистрацию
class RegisterTicketManager
    # Время проверки в секундах
    CHECK_TIME_SECONDS = 60 * 5

    # Экземпляр
    @@instance = RegisterTicketManager.new

    # Заявки
    @tickets = Hash(String, RegisterTicket).new

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

                @tickets.delete_if { |k, link|
                    res = link.expireDate < now
                    p "Register link #{link.ticketId} expired" if res
                    res
                }
            end
        end
    end

    # Создаёт заявку
    def createTicket(login : String, password : String) : RegisterTicket
        ticket = RegisterTicket.new(login, password)
        @tickets[ticket.ticketId] = ticket
        return ticket
    end

    # Получает заявку по идентификатору
    def getTicketById(ticketId : String) : RegisterTicket?
        return @tickets[ticketId]?
    end

    # Удаляет заявку
    def removeTicket(ticket : RegisterTicket)
        @tickets.delete(ticket.ticketId)
    end
end