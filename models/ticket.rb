require_relative('../db/sql_runner')
require_relative('customer')
require_relative('film')

class Ticket

  attr_reader :id, :film_id, :customer_id

  def initialize(options)
    @id = options['id'].to_i if options['id']
    @film_id = options['film_id'].to_i
    @customer_id = options['customer_id'].to_i
  end

  def save()
    sql = "INSERT INTO tickets(
    film_id,
    customer_id
    ) VALUES (
    $1,
    $2
    ) RETURNING id;"
    values = [@film_id, @customer_id]
    @id = SqlRunner.run(sql, values)[0]['id'].to_i
  end

  def self.all()
    sql = "SELECT * FROM tickets;"
    tickets = SqlRunner.run(sql)
    return self.map_tickets(tickets)
  end

  def self.delete_all()
    sql = "DELETE FROM tickets;"
    SqlRunner.run(sql)
  end

  def self.map_tickets(ticket_data)
    return ticket_data.map {|ticket| Ticket.new(ticket)}
  end

end
