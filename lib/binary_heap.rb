class BinaryHeap
  def initialize
    @elements = []
  end

  def inspect
    "<#{self.class.to_s} priority=#{peek}>"
  end

  def push(element)
    @elements << element
    bubble_up!
  end

  def <<(element)
    push element
  end

  def pop
    exchange 0, @elements.size - 1
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

  def compare(element, other)
    element < other
  end

  def exchange(index, other)
    @elements[index], @elements[other] = @elements[other], @elements[index]
    self
  end

  def bubble_up!
    @index = @elements.size - 1
    loop { exchange_parent? ? exchange_parent : break }
    self
  end

  def bubble_down!
    @index = 0
    loop { exchange_child? ? exchange_child : break }
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

  def two_children?
    2 * @index < @elements.size - 2
  end

  def first_child_index
    2 * @index + 1
  end

  def use_second_child?
    compare *@elements.slice(first_child_index, 2)
  end

  def child_index
    if two_children? && use_second_child?
      first_child_index + 1
    else
      first_child_index
    end
  end

  def exchange_parent?
    @index > 0 && compare(parent, element)
  end

  def exchange_parent
    next_index = parent_index
    exchange @index, next_index
    @index = next_index
  end

  def exchange_child?
    child && compare(element, child)
  end

  def exchange_child
    next_index = child_index
    exchange @index, next_index
    @index = next_index
  end
end

class MinBinaryHeap < BinaryHeap
  private

  def compare(element, other)
    element > other
  end
end

