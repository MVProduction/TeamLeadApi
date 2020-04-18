require "./base_dao"

# Для доступа к файлам
class FileDao < BaseDao
    # Инициализирует таблицу
    def init   
        # Создаёт таблицу для объявлений пользователя
        db.exec(
            "CREATE TABLE IF NOT EXISTS files
                (
                    file_id VARCHAR(255) PRIMARY KEY AUTOINCREMENT,                    
                    file_name VARCHAR(255) NOT NULL,
                    file_mime VARCHAR(255) NOT NULL
                )
            ")     
    end

    # Устанавливает метаинформацию файла
    def setFileMeta(fileId : String, fileName : String, fileMime : String)
        result = db.query("SELECT file_id FROM files WHERE file_id=?", fileId)
        if result.move_next
            db.exec("UPDATE files SET file_name=?, file_mime=? WHERE file_id=?", fileName, fileMime, fileId)  
        else
            db.exec("INSERT INTO files(file_id, file_name, file_mime) VALUES(?,?,?)", fileId, fileName, fileMime)
        end
    end 
    
    # Возвращает метаинформацию о файле или null
    def getFileMeta(fileId : String) : DBFileMeta?
        rs = db.query_one?("SELECT file_name, file_mime FROM files WHERE file_id=?", fileId, as: {String, String})
        if rs
            fileName, fileMime = rs
            return DBFileMeta.new(fileId, fileName, fileMime)
        end        

        return nil
    end
end