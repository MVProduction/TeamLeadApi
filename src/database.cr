# Данные о файле
class DBFileMeta
    property fileId : String
    property fileName : String
    property fileMime : String

    def initialize(@fileId, @fileName, @fileMime)
    end
end

# Для работы с базой API
class Database
    @@instance = Database.new

    @database : DB::Database

    def self.instance
        @@instance
    end

    private def initDatabase
        @database.exec(
            "CREATE TABLE IF NOT EXISTS files
                (
                    file_id string,
                    file_name varchar(255),
                    file_mime varchar(255)
                )
            ")
        
        @database.query("SELECT file_id FROM files") do |rs|
            rs.each do
                p rs.read(String)
            end
        end
    end

    def initialize
        @database = DB.open "sqlite3://./teamlead.db"
        initDatabase
    end

    # Устанавливает метаинформацию файла
    def setFileMeta(fileId : String, fileName : String, fileMime : String)
        result = @database.query("SELECT file_id FROM files WHERE file_id=?", fileId)
        if result.move_next
            @database.exec("UPDATE files SET file_name=?, file_mime=? WHERE file_id=?", fileName, fileMime, fileId)  
        else
            @database.exec("INSERT INTO files(file_id, file_name, file_mime) VALUES(?,?,?)", fileId, fileName, fileMime)
        end
    end 
    
    # Возвращает метаинформацию о файле или null
    def getFileMeta(fileId : String) : DBFileMeta?
        rs = @database.query_one?("SELECT file_name, file_mime FROM files WHERE file_id=?", fileId, as: {String, String})
        if rs
            fileName, fileMime = rs
            return DBFileMeta.new(fileId, fileName, fileMime)
        end        

        return nil
    end
end