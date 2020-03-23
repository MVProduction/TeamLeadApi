# Возвращает ответ с кодом
def getCodeResponse(code : Int32) : String
    { code: code }.to_json
end