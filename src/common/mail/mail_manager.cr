require "email"

# Отправляет почту
class MailManager
    # Адрес smtp сервера
    SMTP_HOST = "smtp.yandex.ru"

    # Порт SMTP сервера
    SMTP_PORT = 465

    # Отправитель почты
    SENDER_MAIL = "teamlead2020@yandex.ru"

    # Пароль
    PASSWORD = "NONE66"

    # Экземпляр
    @@instance = MailManager.new

    # Возвращает экземпляр
    def self.instance
        @@instance
    end

    # Отправляет почту
    def sendMail(subject : String, message : String, recepient : String)
        config = EMail::Client::Config.new(SMTP_HOST, SMTP_PORT)
        config.use_auth(SENDER_MAIL, PASSWORD)
        config.connect_timeout = 2

        client = EMail::Client.new(config)

        client.start do            
            mail = EMail::Message.new
            mail.from SENDER_MAIL
            mail.to recepient
            mail.subject subject
            mail.message message        
            send(mail)
        end
    end
end