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
        config = EMail::Client::Config.new(SMTP_HOST)
        config.use_auth(SENDER_MAIL, PASSWORD)        
        config.use_tls(SMTP_PORT)
        config.connect_timeout = 2

        client = EMail::Client.new(config)
            
        p "START CLIENT"
        client.start do
            p "START SEND"
            mail = EMail::Message.new
            mail.from SENDER_MAIL
            mail.to recepient
            mail.subject subject
            mail.message message
            p "START SEND 2"
            send(mail)
            p "SENDED"
        end
    end
end