module DataStructures
  class BinaryHeap
    class Min < BinaryHeap
      private

      def compare(element, other)
        other <=> element
      end
    end

    class Max < BinaryHeap
      private

      def compare(element, other)
        element <=> other
      end
    end

    class WithComparator < BinaryHeap
      def initialize(*elements, &block)
        super(*elements)
        @comparator = block
      end

      private

      def compare(element, other)
        @comparator.call(element, other)
      end
    end

    def initialize(*elements)
      @elements = elements
    end

    def inspect
      "<#{self.class.to_s} priority=#{peek}>"
    end

    def push(element)
      @elements << element
      bubble_up!
    end

    def <<(element)
      push(element)
    end

    def pop
      exchange!(0, @elements.size - 1)
      @elements.pop.tap { bubble_down! }
    end

    def peek
      @elements.first
    end

    def empty?
      @elements.empty?
    end

    def size
      @elements.size
    end

    private

    def compare(_element, _other)
      raise NotImplementedError
    end

    def exchange!(index, other)
      @elements[index], @elements[other] = @elements[other], @elements[index]
      self
    end

    def bubble_up!
      @index = @elements.size - 1
      loop { exchange_parent? ? exchange_parent! : break }
      self
    end

    def bubble_down!
      @index = 0
      loop { exchange_child? ? exchange_child! : break }
      self
    end

    def element
      @elements[@index]
    end

    def parent
      @elements[parent_index]
    end

    def parent_index
      (@index - 1) / 2
    end

    def child
      @elements[child_index]
    end

    def child_index
      two_children? && compare(*children) < 0 ?
        child_indices.last :
        child_indices.first
    end

    def two_children?
      2 * @index < @elements.size - 2
    end

    def child_indices
      [1, 2].map { |offset| 2 * @index + offset }
    end

    def children
      child_indices.map { |index| @elements[index] }
    end

    def exchange_parent?
      @index > 0 && compare(parent, element) < 0
    end

    def exchange_parent!
      parent_index.tap do |index|
        exchange!(@index, index)
        @index = index
      end
    end

    def exchange_child?
      child && compare(element, child) < 0
    end

    def exchange_child!
      child_index.tap do |index|
        exchange!(@index, index)
        @index = index
      end
    end
  end
end