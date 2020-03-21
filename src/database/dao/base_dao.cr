# Базовый объект работы с базой
abstract class BaseDao
    # Для доступа к базе
    getter db : DB::Database

    # Конструктор
    def initialize(@db)
    end

    abstract def initTable
end