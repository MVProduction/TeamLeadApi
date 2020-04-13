require "../database/database"
require "./api_helper"
require "../common/common_constants"
require "../common/common_response_codes"
require "../common/session/session_manager"
require "../common/session/session"
require "../common/register/register_ticket"
require "../common/register/register_manager"
require "../common/mail/mail_manager"

# Ошибка - неправильный логин или пароль
INVALID_LOGIN_OR_PASSWORD = 3000

# Ошибка - пользователь уже существует
USER_ALREADY_EXISTS = 3001

# Заявка на регистрацию не найдена
REGISTER_TICKET_NOT_FOUND_ERROR = 3002

# Проводит аутентификацию по электронной почте и паролю
# Возвращает либо идентификатор сессии
# Или код ошибки
post "/user/loginByMail" do |env|
    begin
        login = env.params.json["login"]?.as?(String)
        password = env.params.json["password"]?.as?(String)
    
        if login.nil? || password.nil?
            next getCodeResponse(BAD_REQUEST_ERROR)
        end

        user = Database.instance.userDao.getUserByEmail(login)
        # Отправляет ошибку если пользователь не найден
        next getCodeResponse(INVALID_LOGIN_OR_PASSWORD) if user.nil?

        if user.password == password
            # Возвращает
            session = SessionManager.instance.getOrCreateSession(user.user_id)
            # Отправляет идентификатор сессии
            next {
                code: OK_CODE,
                sessionId: session.sessionId
            }.to_json
        else
            next getCodeResponse(INVALID_LOGIN_OR_PASSWORD)
        end
    rescue
        next getCodeResponse(INTERNAL_ERROR)
    end
end

# Создаёт заявку на регистрацию
# В заявку помещает логин и пароль пользователя
# Возвращает идентификатор заявки
post "/user/createRegisterTicket" do |env|
    begin
        login = env.params.json["login"]?.as?(String)
        password = env.params.json["password"]?.as?(String)

        if login.nil? || password.nil?
            next getCodeResponse(BAD_REQUEST_ERROR)
        end

        # Проверяет нет ли уже такого пользователя
        user = Database.instance.userDao.getUserByEmail(login)
        next getCodeResponse(USER_ALREADY_EXISTS) if user

        # Создаёт ссылку на подтверждение регистрации
        ticket = RegisterTicketManager.instance.createTicket(login, password)

        next {
            code: OK_CODE,
            ticketId: ticket.ticketId
        }.to_json
    rescue
        next getCodeResponse(INTERNAL_ERROR)
    end
end

# Подтверждает создание пользователя по электронной почте
get "/user/confirmRegisterTicket/:id" do |env|
    begin
        ticketId = env.params.url["id"]
        ticket = RegisterTicketManager.instance.getTicketById(ticketId)
        if (ticket)
            Database.instance.userDao.createUser(ticket.login, ticket.password)
            RegisterTicketManager.instance.removeTicket(ticket)
            next getCodeResponse(OK_CODE)
        end

        next getCodeResponse(REGISTER_TICKET_NOT_FOUND_ERROR)
    rescue
        next getCodeResponse(OK_CODE)
    end
end