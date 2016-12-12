require "matrix"
require "hamster"
require "aoc/list"
require "algebrick"

class AOC::Day1

  Vector = Algebrick.type { fields x: Integer, y: Integer }
  module Vector
    RIGHT = Matrix[
      [0, 1],
      [-1, 0]
    ]

    LEFT = Matrix[
      [0, -1],
      [1, 0]
    ]

    module_function def zero
      Vector[0,0]
    end

    module_function def north
      Vector[0,1]
    end

    def right
      new_heading = RIGHT * Matrix[[self[:x]], [self[:y]]]
      Vector[x: new_heading[0,0], y: new_heading[1,0]]
    end

    def left
      new_heading = LEFT * Matrix[[self[:x]], [self[:y]]]
      Vector[x: new_heading[0,0], y: new_heading[1,0]]
    end

    def *(scalar_distance)
      Vector[x: self[:x] * scalar_distance, y: self[:y] * scalar_distance]
    end

    def +(other_point)
      Vector[x: self[:x] + other_point[:x], y: self[:y] + other_point[:y]]
    end

    def block_distance
      self[:x].abs + self[:y].abs
    end
  end

  Walker = Algebrick.type { fields location: Vector, heading: Vector }
  module Walker
    module_function def default
      Walker[location: Vector.zero, heading: Vector.north]
    end

    def move(distance)
      self.update(location: self[:location] + (self[:heading] * distance))
    end

    def right
      self.update(heading: self[:heading].right)
    end

    def left
      self.update(heading: self[:heading].left)
    end

    def block_distance
      self[:location].block_distance
    end

    def cover(distance)
      (1..distance).map{|d|
        self[:location] + (self[:heading] * d)
      }
    end
  end

  def run(directions)
    Parser.new(directions)
      .inject(Walker.default){|walker, direction|
        walker
          .send(direction.rotation)
          .move(direction.distance)
      }
      .block_distance
  end

  def run_part2(directions)
    state = Algebrick.type { fields visited: Hamster::Set, walker: Walker }

    Parser
      .new(directions)
      .inject(state[visited: Hamster::Set.new, walker: Walker.default]){|current, direction|

        locations = current[:walker]
          .send(direction.rotation)
          .cover(direction.distance)

        visited = locations.inject(current[:visited]){|v, location|
          if v.include?(location)
            return location.block_distance
          else
            v.add(location)
          end
        }

        walker = current[:walker]
          .send(direction.rotation)
          .move(direction.distance)

        state[visited: visited, walker: walker]
      }
    raise "no point visited twice"
  end

  Direction = Struct.new(:rotation, :distance)

  class Parser
    include Enumerable
    include AOC::List

    def initialize(directions)
      @directions = directions
    end

    def each
      direction = nil
      directions = @directions
      begin
        direction, directions = parse_direction(directions)
        yield direction if direction
        directions = parse_separator(directions)
      end while direction
    end

    private
    def parse_direction(directions)
      rotation, directions = parse_rotation(directions)
      distance, directions = parse_distance(directions)
      direction = rotation && distance ? Direction.new(rotation, distance) : nil
      [direction, directions]
    end

    def parse_rotation(directions)
      rotation, new_directions = ht(directions)
      case rotation
      when "R" then [:right, new_directions]
      when "L" then [:left, new_directions]
      else [nil, directions]
      end
    end

    def parse_distance(directions, distance=nil)
      n_str, new_directions = ht(directions)
      begin
        new_distance = (distance || 0) * 10
        new_distance += Integer(n_str)
        parse_distance(new_directions, new_distance)
      rescue ArgumentError, TypeError
        [distance, directions]
      end
    end

    def parse_separator(directions)
      directions = parse_comma(directions)
      parse_space(directions)
    end

    def parse_comma(directions)
      comma, new_directions = ht(directions)
      case comma
      when "," then new_directions
      else directions
      end
    end

    def parse_space(directions)
      space, new_directions = ht(directions)
      case space
      when " " then new_directions
      else directions
      end
    end
  end

end
