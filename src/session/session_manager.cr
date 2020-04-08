# Управляет сессиями
class SessionManager
    # Экземпляр
    @@instance = SessionManager.new
    
    # Словарь с сессиями пользователей
    # Ключём является идентификатор пользователя
    @sessions = Hash(Int64, Session).new

    # Возвращает экземпляр
    def self.instance
        @@instance
    end

    # Возвращает готовую сессию или создаёт новую 
    # Для поиска используется уникальный идентификатор пользователя
    def getOrCreateSession(userId : Int64) : Session
        session = @sessions[userId]?
        return session if session

        session = Session.new(userId)
        @sessions[userId] = session
        return session
    end
end