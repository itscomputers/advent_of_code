require "solver"

module Year2022
  class Day07 < Solver
    def solve(part:)
      case part
      when 1 then file_system.sizes.take_while { |size| size < 100000 }.sum
      when 2 then file_system.sizes.find { |size| size > file_system.excess_space }
      end
    end

    def output_lines
      lines.map { |line| OutputLine.new(line) }
    end

    def file_system
      @file_system ||= FileSystemBuilder.new(output_lines).build
    end

    class FileSystem
      def initialize(root)
        @root = root
      end

      def sizes
        @sizes ||= @root.subdirectories.map(&:size).sort
      end

      def excess_space
        @root.size - 40_000_000
      end

      class Node
        attr_reader :name, :children
        attr_accessor :parent

        def initialize(name, file_size=nil)
          @name = name
          @file_size = file_size
          @children = []
          @parent = nil
        end

        def add_child(node)
          @children << node
        end

        def directory?
          @file_size.nil?
        end

        def subdirectories
          @subdirectories ||= directory? ?
            [*@children.select(&:directory?), *@children.flat_map(&:subdirectories)] :
            []
        end

        def size
          @size ||= @file_size.nil? ? @children.sum(&:size) : @file_size
        end
      end
    end

    class FileSystemBuilder
      def initialize(output_lines)
        @output_lines = output_lines
        @root = FileSystem::Node.new("/")
        @current_node = @root
      end

      def process_output_line
        output_line = @output_lines.shift

        if output_line.change_directory
          dir = output_line.change_directory[:dir]
          cd dir

        elsif output_line.directory
          dir = output_line.directory[:dir]
          build_node(dir, nil)

        elsif output_line.file
          size = output_line.file[:size].to_i
          name = output_line.file[:name]
          build_node(name, size)
        end
      end

      def cd(dir)
        if dir == ".."
          @current_node = @current_node.parent
        elsif dir == "/"
          @current_node = @root
        else
          @current_node = @current_node.children.find { |child| child.name == dir }
        end
      end

      def build_node(name, size)
        FileSystem::Node.new(name, size).tap do |node|
          @current_node.add_child(node)
          node.parent = @current_node
        end
      end

      def build
        process_output_line until @output_lines.empty?
        FileSystem.new(@root)
      end
    end

    class OutputLine < Struct.new(:value)
      def change_directory
        @cd_match ||= value.match(/cd (?<dir>.+)/)
      end

      def directory
        @dir_match ||= value.match(/dir (?<dir>.+)/)
      end

      def file
        @file_match ||= value.match(/(?<size>\d+) (?<name>.+)/)
      end
    end
  end
end
