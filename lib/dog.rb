require "pry"

class Dog
    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name 
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL

         DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end

    def save
      sql = <<-SQL
        INSERT INTO dogs(name, breed)
        VALUES(?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end

    def self.new_from_db(row)
        self.new(id:row[0], name:row[1], breed:row[2])
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
        SQL

        row = DB[:conn].execute(sql, name).flatten
        self.new_from_db(row)
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(name:, breed:)
        new_dog = Dog.new(name: name, breed: breed)
        new_dog.save
        new_dog
    end

    def self.find_by_id(id)
        sql = <<-SQL 
            SELECT *
            FROM dogs 
            WHERE id = ?
        SQL

        row = DB[:conn].execute(sql, id).flatten
        self.new_from_db(row)
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ? AND breed = ?
        SQL

        row = DB[:conn].execute(sql, name, breed).flatten
            if row.empty?
                self.create(name: name, breed: breed)
            else
                self.new_from_db(row)
            end
    end

end
