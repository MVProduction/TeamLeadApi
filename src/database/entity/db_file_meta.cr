# Данные о файле
class DBFileMeta
    # Идентификатор файла
    property fileId : String

    # Имя файла
    property fileName : String

    # Mime тип файла
    property fileMime : String

    # Конструктор
    def initialize(@fileId, @fileName, @fileMime)
    end
end