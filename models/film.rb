require_relative('../db/sql_runner')
require_relative('customer')
require_relative('ticket')

class Film

  attr_reader :id
  attr_accessor :title, :price

  def initialize(options)
    @id = options['id'].to_i if options['id']
    @title = options['title']
    @price = options['price'].to_i
  end

  def save()
    sql = "INSERT INTO films (
    title,
    price
    ) VALUES (
    $1,
    $2
    ) RETURNING id;"
    values = [@title, @price]
    @id = SqlRunner.run(sql, values)[0]['id'].to_i
  end

  def self.all()
    sql = "SELECT * FROM films;"
    films = SqlRunner.run(sql)
    return self.map_films(films)
  end

  def update()
    sql = "UPDATE films SET title = $1, price = $2 WHERE id = $3;"
    values = [@title, @price, @id]
    SqlRunner.run(sql, values)
  end

  def self.delete_all
    sql = "DELETE from films;"
    SqlRunner.run(sql)
  end

  def customers()
    sql = "SELECT customers.* FROM customers
    INNER JOIN tickets
    ON customers.id = tickets.customer_id
    WHERE film_id = $1;"
    values = [@id]
    customers = SqlRunner.run(sql, values)
    return Customer.map_customers(customers)
  end

  def total_customers()
    return customers().count
  end

  def self.map_films(film_data)
    return film_data.map {|film| Film.new(film)}
  end

end
