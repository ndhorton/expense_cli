#!/usr/bin/env ruby

# frozen_string_literal: true

require 'bundler/setup'
require 'date'
require 'pg'

CONNECTION = PG.connect(dbname: 'expense')

def add_expense(amount, memo)
  date = Date.today
  sql = 'INSERT INTO expenses (amount, memo, created_on) VALUES ($1, $2, $3);'
  CONNECTION.exec_params(sql, [amount, memo, date])
end

def display_help
  puts <<~HELP
    An expense recording system

    Commands:

    add AMOUNT MEMO - record a new expense
    clear - delete all expenses
    list - list all expenses
    delete NUMBER - remove expense with id NUMBER
    search QUERY - list expenses with a matching memo field
  HELP
end

def list_expenses
  result = CONNECTION.exec_params('SELECT * FROM expenses ORDER BY created_on ASC;')

  result.each do |tuple|
    columns = [tuple['id'].rjust(3),
               tuple['created_on'].rjust(10),
               tuple['amount'].rjust(12),
               tuple['memo']]

    puts columns.join(' | ')
  end
end

command = ARGV.first
case command
when 'add'
  amount = ARGV[1]
  memo = ARGV[2]
  if amount.nil? || memo.nil?
    puts 'You must provide an amount and memo.'
  else
    add_expense(amount, memo)
  end
when 'list' then list_expenses
else
  display_help
end

CONNECTION.close
