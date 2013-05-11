#!/usr/bin/ruby
# coding: utf-8

require 'rubygems'
require 'dbf'
require 'progressbar'

def numeric? ( object )
  true if Float(object) rescue false
end

def convert ( file )
  sqlfile = file.gsub(/\.\//i, '').gsub(/\.dbf/i, '.sql').downcase!
  
  file = file.gsub(/\.\//i, '')
  
  table = DBF::Table.new(file)

  puts "Вычисляю количество строк в базе #{file}"
  rows = table.count
  puts "Строк в базе: #{rows}"

  pbar = ProgressBar.new(file, rows)

  i = 0
  table.each do |rec|
    i += 1

    count = rec.attributes.length

    if ( i == 1 )
      prefix = ''
      q = 0
      rec.attributes.keys.each do |key|
        q += 1
        prefix += '`' + key.downcase + '`' + ( qe = (q == count) ? '' : ', ' )
      end

      File.open(sqlfile, 'w') { |file| file.write "INSERT INTO `#{sqlfile.gsub(/\.sql/i, '')}` (#{prefix}) VALUES \n" }
    end

    File.open(sqlfile, 'a') { |file| file.write '(' }

    j = 0
    rec.attributes.each do |k, v|
      j += 1

      v = ( v.nil? ) ? '""' : ( numeric?( v ) ) ? v : ( v.kind_of?(String) ) ? '"' + v + '"' : v

      File.open(sqlfile, 'a') { |file| file.write v.force_encoding("CP866").encode("UTF-8") + ( je = (j == count) ? '' : ', ' ) }
    end

    File.open(sqlfile, 'a') { |file| file.write ')' + ( ie = (i == rows) ? ';' : ", \n" ) }
    
    pbar.inc
  end

  pbar.finish
end

Dir.glob("./*.DBF") { |file|  convert ( file ) }

