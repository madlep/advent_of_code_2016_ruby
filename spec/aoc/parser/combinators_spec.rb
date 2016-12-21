require "aoc/parser/combinators"

RSpec.describe AOC::Parser::Combinators do
  include AOC::Parser::Combinators

  Result = AOC::Parser::Combinators::Result
  NoResult = AOC::Parser::Combinators::NoResult
  Discard = AOC::Parser::Combinators::Discard
  ParseError = AOC::Parser::Combinators::ParseError

  describe "#term generated parser" do
    it "parses a term from string" do
      parser = term("foo")
      expect(parser.call("foobar")).to eq(
        Result[value: "foo", remaining: "bar", label: Discard]
      )
    end

    it "raises a parse error when term is not at start of string" do
      parser = term("foo")
      expect{parser.call("fuzboz")}.to raise_error(ParseError)
    end

    it "can have a label" do
      parser = term("foo", label: :my_label)
      expect(parser.call("foobar")).to eq(
        Result[value: "foo", remaining: "bar", label: :my_label]
      )
    end
  end

  describe "#match generated parser" do
    it "parses regex from string" do
      parser = match(/[0-9]+/)
      expect(parser.call("1234 I like cheese")).to eq(
        Result[value: "1234", remaining: " I like cheese", label: Discard]
      )
    end

    it "matches at start of string only" do
      parser = parser = match(/[0-9]+/)
      expect{parser.call("foo bar 123 baz")}.to raise_error(ParseError)
    end

    it "can have a label" do
      parser = parser = match(/[0-9]+/, label: :my_label)
      expect(parser.call("1234 I like cheese")).to eq(
        Result[value: "1234", remaining: " I like cheese", label: :my_label]
      )
    end
  end

  describe "#int generated parser" do
    it "parses integers from string" do
      parser = int()
      expect(parser.call("1234 I like cheese")).to eq(
        Result[value: 1234, remaining: " I like cheese", label: Discard]
      )
    end

    it "can have a label" do
      parser = int(label: :my_label)
      expect(parser.call("1234 I like cheese")).to eq(
        Result[value: 1234, remaining: " I like cheese", label: :my_label]
      )
    end

    it "complains when an integer can't be parsed" do
      parser = int()
      expect{parser.call("zzzz1234 I like cheese")}.to raise_error(ParseError)
    end
  end

  describe "#maybe generated parser" do
    it "returns included parser result if it parses" do
      child_parser = term("cheese")
      parser = maybe(child_parser)
      expect(parser.call("cheese is nice")).to eq(
        Result[
          value: Result[value: "cheese", remaining: " is nice", label: Discard],
          remaining: " is nice",
          label: Discard
        ]
      )
    end

    it "doesn't complain if child doesn't parse" do
      child_parser = term("cheese")
      parser = maybe(child_parser)
      expect(parser.call("tube cheese is not nice")).to eq(
        NoResult[remaining: "tube cheese is not nice", label: Discard]
      )
    end
  end

  describe "#one_of generated parser" do
    it "returns first parser that parses" do
      parser = one_of(term("foo"), term("bar"))

      expect(parser.call("foobroz")).to eq(
        Result[
          value: Result[value: "foo", remaining: "broz", label: Discard],
          remaining: "broz",
          label: Discard
        ]
      )

      expect(parser.call("barfuz")).to eq(
        Result[
          value: Result[value: "bar", remaining: "fuz", label: Discard],
          remaining: "fuz",
          label: Discard
        ]
      )
    end

    it "complains if no parsers parse" do
      parser = one_of(term("foo"), term("bar"))
      expect{parser.call("cheese")}.to raise_error(ParseError)
    end
  end

  describe "#many generated parser" do
    it "parses multiple repeats of a parser" do
      parser = many(term('foo'))
      expect(parser.call('foofoofoobarbar')).to eq(
        Result[
          value: [
            Result[value: "foo", remaining: "foofoobarbar", label: Discard],
            Result[value: "foo", remaining: "foobarbar", label: Discard],
            Result[value: "foo", remaining: "barbar", label: Discard]
          ],
          remaining: "barbar",
          label: Discard
        ]
      )
    end

    it "complains if at least one instance of parser can't parse the string" do
      parser = many(term("foo"))
      expect{parser.call("cheese")}.to raise_error(ParseError)
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
      expect(parser.call("I like cheese")).to eq(
        Result[
          value: [
            Result[value: "I", remaining: " like cheese", label: Discard],
            Result[value: " ", remaining: "like cheese", label: Discard],
            Result[value: "like", remaining: " cheese", label: Discard],
            Result[value: " ", remaining: "cheese", label: Discard],
            Result[value: "cheese", remaining: "", label: Discard]
          ],
          remaining: "",
          label: Discard
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
      expect{parser.call("I don't like cheese")}.to raise_error(ParseError)
    end
  end

  describe "#space generated parser" do
    it "parses whitespace" do
      parser = space()
      expect(parser.call("  foobar")).to eq(
        Result[value: "  ", remaining: "foobar", label: Discard]
      )
    end
  end
end
