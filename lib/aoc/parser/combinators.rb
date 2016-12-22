require "aoc"
require "aoc/parser"

module AOC::Parser::Combinators
  include Algebrick::Matching

  ParseResult = Algebrick.type {
    variants  NoResult = type { fields! remaining: String}
              Result = type { fields! value: Object, remaining: String}
              CaptureResult = type { fields! value: Object, remaining: String}
  }
  module Result
    def fmap(&f)
      self.update(value: f.(self.value))
    end

    def capture()
      CaptureResult[value: self.value, remaining: self.remaining]
    end
  end

  module NoResult
    def capture()
      self
    end
  end

  module CaptureResult
    def captures
      match self.value,
        on(Enumerable){
          self.value.inject(Hamster::Vector[]){|caps, v|
            match v,
              on(CaptureResult){ caps.add(v.captures) },
              on(any, caps)
          }
        },
        on(any, self.value)
    end
  end

  class ParseError < StandardError; end

  def capture(parser)
    ->(str) {
      parser.(str).capture
    }
  end

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
  def term!(t); capture(term(t)); end

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
  def match!(regex); capture(match(regex)); end

  def symbol(symbol)
    term_parser = term(symbol.to_s)
    ->(str) {
      term_parser.(str).fmap{|v| v.to_sym }
    }
  end
  def symbol!(symbol); capture(symbol(symbol)); end

  def int()
    matcher = match(/[0-9]+/)
    -> (str) {
      matcher.(str).fmap{|v| Integer(v) }
    }
  end
  def int!(); capture(int()); end

  def maybe(parser)
    ->(str) {
      begin
        parser.(str)
      rescue ParseError
        NoResult[remaining: str]
      end
    }
  end
  def maybe!(parser); capture(maybe(parser)); end

  def one_of(*parsers)
    ->(str) {
      parsers.each do |parser|
        begin
          return parser.(str)
        rescue ParseError
          next
        end
      end
      raise ParseError, "could not parse one_of in #{str}"
    }
  end
  def one_of!(*parsers); capture(one_of(parsers)); end

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
  def many!(parser); capture(many(parser)); end

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
  def seq!(*parsers); capture(seq(*parsers)); end

  def space()
    match(/\s+/)
  end
  def space!(); capture(space());end

  def eol()
    match(/\n/)
  end
  def eol!(); capture(eol()); end

  def eof()
    match(/\z/)
  end
  def eof!(); capture(eof()); end
end
