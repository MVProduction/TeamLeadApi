require "../database/database"
require "./api_helper"
require "../common/common_response_codes"
require "../common/session/session_manager"
require "../common/session/session"
require "../common/register/register_link"
require "../common/register/register_manager"

# Ошибка - неправильный логин или пароль
INVALID_LOGIN_OR_PASSWORD = 3000

# Ошибка - пользователь уже существует
USER_ALREADY_EXISTS = 3001

# Проводит аутентификацию по электронной почте и паролю
# Возвращает либо идентификатор сессии
# Или код ошибки
post "/user/mailLogin" do |env|
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

# Регистрирует нового пользователя используя почту и пароль
# Возвращает код ответа
post "/user/mailRegister" do |env|
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
        link = RegisterLinkManager.instance.createLink()

        # Отправляет на электронную почту письмо с подтверждением регистрации

        next getCodeResponse(OK_CODE)
    rescue
        next getCodeResponse(INTERNAL_ERROR)
    end
end