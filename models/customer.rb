require_relative('../db/sql_runner')
require_relative('customer')
require_relative('ticket')

class Customer

  attr_reader :id
  attr_accessor :name, :funds

  def initialize(options)
    @id = options['id'].to_i if options['id']
    @name = options['name']
    @funds = options['funds'].to_i
  end

  def save()
    sql = "INSERT INTO customers (
    name,
    funds
    ) VALUES (
    $1,
    $2
    ) RETURNING id;"
    values = [@name, @funds]
    @id = SqlRunner.run(sql, values)[0]['id'].to_i
  end

  def self.all
    sql = "SELECT * FROM customers;"
    customers = SqlRunner.run(sql)
    return self.map_customers(customers)
  end

  def update()
    sql = "UPDATE customers SET name = $1, funds = $2 WHERE id = $3;"
    values = [@name, @funds, @id]
    SqlRunner.run(sql, values)
  end

  def self.delete_all()
    sql = "DELETE FROM customers;"
    SqlRunner.run(sql)
  end

  def films()
    sql = "SELECT films.* FROM films
    INNER JOIN tickets
    ON tickets.film_id = films.id
    WHERE customer_id = $1;"
    values = [@id]
    films = SqlRunner.run(sql, values)
    return Film.map_films(films)
  end

  def buy_ticket(film)
    @funds -= film.price
  end

  def total_tickets()
    sql = "SELECT * FROM tickets
    WHERE customer_id = $1;"
    values = [@id]
    tickets = Ticket.map_tickets(SqlRunner.run(sql, values))
    return tickets.count()
  end

  def self.map_customers(customer_data)
    return customer_data.map {|customer| Customer.new(customer)}
  end

end
