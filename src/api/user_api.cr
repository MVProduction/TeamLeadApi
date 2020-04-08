require "../database/database"
require "./api_helper"
require "../common/common_response_codes"
require "../session/session_manager"
require "../session/session"

# Ошибка - неправильный логин или пароль
INVALID_LOGIN_OR_PASSWORD = 3000

# Проводит аутентификацию по электронной почте и паролю
# Возвращает либо идентификатор сессии
# Или код ошибки
post "/user/mailLogin" do |env|
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
end