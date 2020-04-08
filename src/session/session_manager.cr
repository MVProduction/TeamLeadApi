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

    # Конструктор
    def initialize
        spawn do
            loop do
                sleep(5)
                
                now = Time.utc

                @sessions.delete_if { |k, session|
                    res = session.expireDate < now
                    p "Session #{session.sessionId} expired" if res
                    res
                }
            end            
        end
    end

    # Возвращает готовую сессию или создаёт новую 
    # Для поиска используется уникальный идентификатор пользователя
    def getOrCreateSession(userId : Int64) : Session
        session = @sessions[userId]?
        if session
            session.makeLive
            return session
        end

        session = Session.new(userId)        
        @sessions[userId] = session
        return session
    end
end