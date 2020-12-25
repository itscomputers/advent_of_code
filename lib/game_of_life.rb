class GameOfLife
  attr_reader :active

  def initialize(**options)
    @active = Set.new
  end

  def activate!(*points)
    @active.merge points
    self
  end

  def deactivate!(*points)
    @active.subtract points
    self
  end

  def directions
    @directions ||= [
      [-1,  1], [0,  1], [1,  1],
      [-1,  0],          [1,  0],
      [-1, -1], [0, -1], [1, -1],
    ]
  end

  def neighbors_of(point)
    directions.map do |direction|
      point.zip(direction).map(&:sum)
    end
  end

  def active?(point)
    @active.include? point
  end

  def select_active(points)
    @active & points
  end

  def active_count(points)
    select_active(points).size
  end

  def condition_for(status)
    case status
    when :activating then lambda { |count| count == 3 }
    when :deactivating then lambda { |count| !count.between?(2, 3) }
    end
  end

  def action(active, count)
    if !active && condition_for(:activating).call(count)
      :activate!
    elsif active && condition_for(:deactivating).call(count)
      :deactivate!
    end
  end

  def activation_data
    inactive_neighbors = Set.new

    result = @active.each_with_object(Hash.new) do |point, hash|
      neighbors = neighbors_of(point).each do |neighbor|
        inactive_neighbors.add neighbor unless active?(neighbor)
      end
      hash[point] = action(true, active_count(neighbors))
    end

    inactive_neighbors.each do |point|
      result[point] = action(false, active_count(neighbors_of point))
    end

    result
  end

  def next_generation
    activation_data.each do |point, action|
      next if action.nil?
      send action, point
    end
  end

  def after(generations:)
    generations.times { next_generation }
    self
  end
end

