require "../database/database"
require "../common/common_response_codes"

# Проводит аутентификацию по электронной почте и паролю
# Возвращает либо идентификатор сессии
# Или код ошибки
get "/user/mailLogin" do |env|
    login = env.params.json["login"]?.as?(String)
    password = env.params.json["password"]?.as?(String)
  
    if login.nil? || password.nil?
        next getCodeResponse(BAD_REQUEST_ERROR)
    end

    user = Database.instance.userDao.getUserByEmail(login)
    if user.password == password

    else

    end
end