require_relative '../db/sql_runner'
require 'pry'

class Deal
  attr_accessor :name, :burger_id, :days, :value
  attr_reader :id

  def initialize options
    @name = options['name']
    @burger_id = options['burger_id'].to_i
    @days = options['days']
    @value = options['value']
    @id = nil
  end

  def save
    sql = "
      INSERT INTO deals (name, burger_id, days, value)
      VALUES ($1, $2, $3, $4)
      RETURNING id;
    "
    values = [@name, @burger_id, @days, @value]
    @id = SqlRunner.run(sql, values).first['id'].to_i
  end

  def self.todays_deal
    deals = Deal.all
    current_day = Time.now.strftime("%a")
    deals_available =[]

    deals.each do |deal|
      deal_days = deal.days.split(',')
      if deal_days.include? current_day
        deals_available << deal
      end
    end
    return deals_available
  end

  def self.all
    sql = "
      SELECT * FROM deals;
    "
    result = SqlRunner.run sql
    return result.first != nil ? result.map { |e| Deal.new(e) } : nil
  end

  def self.delete_all
    sql = "
      DELETE FROM deals;
    "
    SqlRunner.run sql
  end
end
