require "aoc/parser/combinators"

RSpec.describe AOC::Parser::Combinators do
  include AOC::Parser::Combinators

  Result = AOC::Parser::Combinators::Result
  NoResult = AOC::Parser::Combinators::NoResult
  CaptureResult = AOC::Parser::Combinators::CaptureResult
  ParseError = AOC::Parser::Combinators::ParseError

  describe "#term generated parser" do
    it "parses a term from string" do
      parser = term("foo")
      expect(parser.("foobar")).to eq(
        Result[value: "foo", remaining: "bar"]
      )
    end

    it "raises a parse error when term is not at start of string" do
      parser = term("foo")
      expect{parser.("fuzboz")}.to raise_error(ParseError)
    end
  end

  describe "#capture generated parser" do
    it "converts Result into a CaptureResult" do
      parser = capture(term("cheese"))
      expect(parser.("cheese is fun")).to eq(CaptureResult[value: "cheese", remaining: " is fun"])
    end

    it "keeps NoResult as NoResult" do
      parser = capture(maybe(term("fuz")))
      expect(parser.("foobar")).to eq(NoResult[remaining: "foobar"])
    end
  end

  describe "#match generated parser" do
    it "parses regex from string" do
      parser = match(/[0-9]+/)
      expect(parser.("1234 I like cheese")).to eq(
        Result[value: "1234", remaining: " I like cheese"]
      )
    end

    it "matches at start of string only" do
      parser = parser = match(/[0-9]+/)
      expect{parser.("foo bar 123 baz")}.to raise_error(ParseError)
    end
  end

  describe "symbol generated parser" do
    it "parses terms and converts to symbols" do
      parser = symbol(:foobar)
      expect(parser.("foobar is baz")).to eq(
        Result[value: :foobar, remaining: " is baz"]
      )
    end

    it "complains when symbol can't be parsed" do
      parser = symbol(:foobar)
      expect{parser.("fuzbar is baz")}.to raise_error(ParseError)
    end
  end

  describe "#int generated parser" do
    it "parses integers from string" do
      parser = int()
      expect(parser.("1234 I like cheese")).to eq(
        Result[value: 1234, remaining: " I like cheese"]
      )
    end

    it "complains when an integer can't be parsed" do
      parser = int()
      expect{parser.("zzzz1234 I like cheese")}.to raise_error(ParseError)
    end
  end

  describe "#maybe generated parser" do
    it "returns included parser result if it parses" do
      child_parser = term("cheese")
      parser = maybe(child_parser)
      expect(parser.("cheese is nice")).to eq(
        Result[value: "cheese", remaining: " is nice"]
      )
    end

    it "doesn't complain if child doesn't parse" do
      child_parser = term("cheese")
      parser = maybe(child_parser)
      expect(parser.("tube cheese is not nice")).to eq(
        NoResult[remaining: "tube cheese is not nice"]
      )
    end
  end

  describe "#one_of generated parser" do
    it "returns first parser that parses" do
      parser = one_of(term("foo"), term("bar"))

      expect(parser.("foobroz")).to eq(
        Result[value: "foo", remaining: "broz"]
      )

      expect(parser.("barfuz")).to eq(
        Result[value: "bar", remaining: "fuz"]
      )
    end

    it "complains if no parsers parse" do
      parser = one_of(term("foo"), term("bar"))
      expect{parser.("cheese")}.to raise_error(ParseError)
    end
  end

  describe "#many generated parser" do
    it "parses multiple repeats of a parser" do
      parser = many(term('foo'))
      expect(parser.('foofoofoobarbar')).to eq(
        Result[
          value: [
            Result[value: "foo", remaining: "foofoobarbar"],
            Result[value: "foo", remaining: "foobarbar"],
            Result[value: "foo", remaining: "barbar"]
          ],
          remaining: "barbar"
        ]
      )
    end

    it "complains if at least one instance of parser can't parse the string" do
      parser = many(term("foo"))
      expect{parser.("cheese")}.to raise_error(ParseError)
    end
  end

  describe "#seq generated parser" do
    it "applies each parser in sequence" do
      parser = seq(
        term("I"),
        space(),
        term("like"),
        space(),
        match(/\w+/)
      )
      expect(parser.("I like cheese")).to eq(
        Result[
          value: [
            Result[value: "I", remaining: " like cheese"],
            Result[value: " ", remaining: "like cheese"],
            Result[value: "like", remaining: " cheese"],
            Result[value: " ", remaining: "cheese"],
            Result[value: "cheese", remaining: ""]
          ],
          remaining: ""
        ]
      )
    end

    it "blows up if parsers in sequence don't parse" do
      parser = seq(
        term("I"),
        space(),
        term("like"),
        space(),
        match(/\w+/)
      )
      expect{parser.("I don't like cheese")}.to raise_error(ParseError)
    end
  end

  describe "#space generated parser" do
    it "parses whitespace" do
      parser = space()
      expect(parser.("  foobar")).to eq(
        Result[value: "  ", remaining: "foobar"]
      )
    end
  end

  describe "#eol generated parser" do
    it "parses end of line character" do
      parser = eol()
      expect(parser.("\nfoobar")).to eq(
        Result[value: "\n", remaining: "foobar"]
      )
    end

    it "complains if end of line can't be parsed" do
      parser = eol()
      expect{parser.("not\nfoobar")}.to raise_error(ParseError)
    end
  end

  describe "#eof generated parser" do
    it "parses end of file character" do
      parser = eof()
      expect(parser.("")).to eq(
        Result[value: "", remaining: ""]
      )
    end

    it "complains if end of line can't be parsed" do
      parser = eof()
      expect{parser.("not\nfoobar")}.to raise_error(ParseError)
    end
  end
end
