require "matrix"
require "hamster"

class Day1

  class Point
    RIGHT = Matrix[
      [0, 1],
      [-1, 0]
    ]

    LEFT = Matrix[
      [0, -1],
      [1, 0]
    ]

    attr_reader :location

    def initialize(location=Matrix[[0],[0]], heading=Matrix[[0],[1]])
      @location = location
      @heading = heading
    end

    def right
      Point.new(@location, RIGHT * @heading)
    end

    def left
      Point.new(@location, LEFT * @heading)
    end

    def move(distance)
      Point.new(@location + (@heading * distance), @heading)
    end

    def cover(distance)
      (1..distance).map{|d|
        Point.new(@location + (@heading * d), @heading)
      }
    end

    def block_distance
      @location[0,0].abs + @location[1,0].abs
    end

    def hash
      @location.hash
    end

    def ==(other)
      @location == other.location
    end
    alias :eql? :==

    def to_s
      "@location=#{@location} @heading=#{@heading}"
    end
  end

  def run(directions)
    Parser.new(directions)
      .inject(Point.new){|point, direction|
        point
          .send(direction.rotation)
          .move(direction.distance)
      }
      .block_distance
  end

  def run_part2(directions)
    Parser.new(directions).inject({visited: Hamster::Set.new, current: Point.new}){|state, direction|
      points = state[:current]
        .send(direction.rotation)
        .cover(direction.distance)

      visited = points.inject(state[:visited]){|v, point|
        if v.include?(point)
          return point.block_distance
        else
          v.add(point)
        end
      }

      {visited: visited, current: points.last}
    }
    raise "no point visited twice"
  end

  Direction = Struct.new(:rotation, :distance)

  class Parser
    include Enumerable

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

    def ht(s)
      h = s[0]
      t = s[1..-1]
      [h,t]
    end
  end

end
