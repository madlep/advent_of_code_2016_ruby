require "aoc"
require "aoc/parser"

module AOC::Parser::Combinators

  ParseResult = Algebrick.type {
    variants  NoResult = type { fields! remaining: String}
              Result = type { fields! value: Object, remaining: String}
  }
  module Result
    def fmap(&f)
      self.update(value: f.(self.value))
    end
  end

  class ParseError < StandardError; end

  def term(t)
    ->(str) {
      if str.start_with?(t)
        remaining = str[t.length..-1]
        Result[value: t, remaining: remaining]
      else
        raise ParseError, "expecting #{t} at #{str}"
      end
    }
  end

  def match(regex)
    ->(str) {
      r = /\A#{regex}/
      m = r.match(str)
      if m
        value = m[0]
        remaining = str[value.length..-1]
        Result[value: value, remaining: remaining]
      else
        raise ParseError, "expecting #{regex.inspect} at #{str}"
      end
    }
  end

  def int()
    matcher = match(/[0-9]+/)
    -> (str) {
      matcher.call(str).fmap{|v| Integer(v) }
    }
  end

  def maybe(parser)
    ->(str) {
      begin
        parser_result = parser.(str)
        Result[value: parser_result, remaining: parser_result.remaining]
      rescue ParseError
        NoResult[remaining: str]
      end
    }
  end


  def one_of(*parsers)
    ->(str) {
      parsers.each do |parser|
        begin
          parser_result = parser.(str)
          return Result[value: parser_result, remaining: parser_result.remaining]
        rescue ParseError
          false
        end
      end
      raise ParseError, "could not parse one_of in #{str}"
    }
  end

  def many(parser)
    ->(str) {
      new_str = str
      results = Hamster::Vector.new
      while true
        begin
          result = parser.(new_str)
          results = results.add(result)
          new_str = result.remaining
        rescue ParseError => e
          if results.empty?
            raise e
          else
            return Result[value: results, remaining: new_str]
          end
        end
      end
    }
  end

  def seq(*parsers)
    ->(str) {
      remaining_str = str
      result_value = parsers.inject(Hamster::Vector.new){|values, parser|
        result = parser.(remaining_str)
        remaining_str = result.remaining
        values.add(result)
      }
      Result[value: result_value, remaining: remaining_str]
    }
  end

  def space()
    match(/\s+/)
  end
end
