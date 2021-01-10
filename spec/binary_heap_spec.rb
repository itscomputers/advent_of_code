require 'binary_heap'

describe BinaryHeap do
  let(:binary_heap) { BinaryHeap.new }
  let(:popped_elements) do
    binary_heap.size.times.reduce([]) { |array, _| array << binary_heap.pop }
  end

  before { 1000.times { binary_heap << Random.rand(0..10**6) } }

  it "pops them out from largest to smallest" do
    expect(binary_heap).to_not be_empty
    max_element = binary_heap.peek
    expect(popped_elements.sort).to eq popped_elements.reverse
    expect(popped_elements.first).to eq max_element
    expect(binary_heap).to be_empty
  end
end

describe MinBinaryHeap do
  let(:binary_heap) { MinBinaryHeap.new }
  let(:popped_elements) do
    binary_heap.size.times.reduce([]) { |array, _| array << binary_heap.pop }
  end

  before { 1000.times { binary_heap << Random.rand(0..10**6) } }

  it "pops them out from smallest to largest" do
    expect(binary_heap).to_not be_empty
    min_element = binary_heap.peek
    expect(popped_elements.sort).to eq popped_elements
    expect(popped_elements.first).to eq min_element
    expect(binary_heap).to be_empty
  end
end

