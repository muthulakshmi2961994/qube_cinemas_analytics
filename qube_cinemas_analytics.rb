class QubeCinemasAnalytics

  # Initialized partner and capacities csv
  # Formed hash
  # sample_output: {"T1"=>{"P1"=>[{:"Size Slab (IN GB)"=>"0-100", :"Minimum Cost"=>"1500", :"Cost Per GB"=>"20"}, {:"Size Slab (IN GB)"=>"100-200", :"Minimum Cost"=>"2000", :"Cost Per GB"=>"13"}, {:"Size Slab (IN GB)"=>"200-300", :"Minimum Cost"=>"2500", :"Cost Per GB"=>"12"}, {:"Size Slab (IN GB)"=>"300-400", :"Minimum Cost"=>"3000", :"Cost Per GB"=>"10"}], "P2"=>[{:"Size Slab (IN GB)"=>"0-200", :"Minimum Cost"=>"1000", :"Cost Per GB"=>"20"}, {:"Size Slab (IN GB)"=>"200-400", :"Minimum Cost"=>"2500", :"Cost Per GB"=>"15"}], "P3"=>[{:"Size Slab (IN GB)"=>"100-200", :"Minimum Cost"=>"800", :"Cost Per GB"=>"25"}, {:"Size Slab (IN GB)"=>"200-600", :"Minimum Cost"=>"1200", :"Cost Per GB"=>"30"}]}, "T2"=>{"P1"=>[{:"Size Slab (IN GB)"=>"0-100", :"Minimum Cost"=>"1500", :"Cost Per GB"=>"20"}, {:"Size Slab (IN GB)"=>"100-200", :"Minimum Cost"=>"2000", :"Cost Per GB"=>"15"}, {:"Size Slab (IN GB)"=>"200-300", :"Minimum Cost"=>"2500", :"Cost Per GB"=>"12"}, {:"Size Slab (IN GB)"=>"300-400", :"Minimum Cost"=>"3000", :"Cost Per GB"=>"10"}], "P2"=>[{:"Size Slab (IN GB)"=>"0-200", :"Minimum Cost"=>"2500", :"Cost Per GB"=>"20"}, {:"Size Slab (IN GB)"=>"200-400", :"Minimum Cost"=>"3500", :"Cost Per GB"=>"10"}], "P3"=>[{:"Size Slab (IN GB)"=>"100-200", :"Minimum Cost"=>"900", :"Cost Per GB"=>"15"}, {:"Size Slab (IN GB)"=>"200-400", :"Minimum Cost"=>"1000", :"Cost Per GB"=>"12"}]}} 
  def initialize
    partners_csv = './partners.csv'
    capacities_csv = './capacities.csv'
    # Partners hash
    @h = Hash.new{|h,k| h[k] = Hash.new(&h.default_proc) }
    # Capactities hash
    @capacities_hash = Hash.new
    CSV.foreach(partners_csv, headers: true) do |row|
      @h[row['Theatre'].strip][row['Partner ID'].strip] = [] if @h[row['Theatre'].strip][row['Partner ID'].strip].empty?
      @h[row['Theatre'].strip][row['Partner ID'].strip] << { 'Size Slab (IN GB)': row['Size Slab (in GB)'].strip, 'Minimum Cost': row['Minimum cost'].strip, 'Cost Per GB': row['Cost Per GB'].strip }
    end
    CSV.foreach(capacities_csv, headers: true) do |row|
      @capacities_hash[row['Partner ID'].strip] = row['Capacity (in GB)'].strip
    end
  end

  # First problem statement
  # Input_csv as a argument
  # Done business logic
  # created output csv
  # sample output
  # D1,true,2000,P1
  # D2,true,3000,P1
  # D3,true,3500,P1
  def perform_first(input_csv)
    partner = false
    delivery = ""
    output = []
    total_cost = 0
    count = 0
    sum = 0
    CSV.foreach(input_csv, headers: false) do |row|
      # Each row of partners hash
      # sample: {"P1"=>[{:"Size Slab (IN GB)"=>"0-100", :"Minimum Cost"=>"1500", :"Cost Per GB"=>"20"}, {:"Size Slab (IN GB)"=>"100-200", :"Minimum Cost"=>"2000", :"Cost Per GB"=>"13"}, {:"Size Slab (IN GB)"=>"200-300", :"Minimum Cost"=>"2500", :"Cost Per GB"=>"12"}, {:"Size Slab (IN GB)"=>"300-400", :"Minimum Cost"=>"3000", :"Cost Per GB"=>"10"}], "P2"=>[{:"Size Slab (IN GB)"=>"0-200", :"Minimum Cost"=>"1000", :"Cost Per GB"=>"20"}, {:"Size Slab (IN GB)"=>"200-400", :"Minimum Cost"=>"2500", :"Cost Per GB"=>"15"}], "P3"=>[{:"Size Slab (IN GB)"=>"100-200", :"Minimum Cost"=>"800", :"Cost Per GB"=>"25"}, {:"Size Slab (IN GB)"=>"200-600", :"Minimum Cost"=>"1200", :"Cost Per GB"=>"30"}]} 
      values = []
      stripped_row = row.collect(&:strip)
      values << stripped_row[0]
      @h[stripped_row[2]].each do |k, v|
        # k = partner ids
        # v = size_slab, minimum_cost, cost_per_gb arrays
        v.each do |a|
          #  a = Each array of size_slab, minimum_cost, cost_per_gb
          if find_range(a[:"Size Slab (IN GB)"], stripped_row[1])
            partner = true
            # Calculate minimum cost
            mul_value = (a[:"Cost Per GB"].to_i * stripped_row[1].to_i)
            if mul_value >= a[:"Minimum Cost"].to_i
              if count > 0
                if mul_value < sum
                  sum = mul_value
                  delivery = k
                  total_cost = sum
                end
              else
                sum = mul_value
                delivery = k
                total_cost = sum
                count += 1
              end
            end
          end
        end
      end
      count = 0
      # Assinging output values
      values << true if partner == true
      values << total_cost
      values << delivery
      values.join(' ')
      output << values
    end
    # To create output csv
    create_output_csv(output)
  end 

  # To create output csv
  # sample_output: Csv created
  def create_output_csv(output)
    CSV.open("./output.csv", "wb") do |csv|
      output.each do |row|
        csv << row
      end
    end
  end

  # To find: input value is present in the size_slzb range
  # Ruby include method is used
  # sample_output: ((1..100).include? 1) returns -> true
  def find_range(size_slab, input)
    min = size_slab.split('-')[0].to_i
    max = size_slab.split('-')[1].to_i
    (min..max).include? input.to_i
  end

  # To calculate total_cost
  # inputs: a = Each array of size_slab, minimum_cost, cost_per_gb
  #         stripped_row = Each stripped row of partners hash 
  #         k = partner Ids
  # Business logic done
  # Sample ouput: 2500, P1
  def calculate_total_cost(a, stripped_row, k)
    total_cost = 0
    count = 0
    sum = 0
    delivery = ""
    mul_value = (a[:"Cost Per GB"].to_i * stripped_row[1].to_i)
    if mul_value >= a[:"Minimum Cost"].to_i
      if count > 0
        if mul_value < sum
          sum = mul_value
          delivery = k
          total_cost = sum
          return total_cost, delivery
        end
      else
        sum = mul_value
        count += 1
        total_cost = sum
        delivery = k
        return total_cost, delivery
      end
    end
  end

  # To perform second problem statement
  # Input csv as a argument
  # Done business logic
  # created output csv
  # sample output
  # D1,true,2000,P1
  # D2,true,3000,P1
  # D3,true,3500,P1
  def perform_second(input_csv)
    partner = false
    delivery = ""
    output = []
    total_cost = 0
    count = 0
    sum = 0
    low_delivery = 0
    total_delivery = 0
    assigned_capacity = 0
    CSV.foreach(input_csv, headers: false) do |row|
      # Each row of partners hash
      # sample row: {"P1"=>[{:"Size Slab (IN GB)"=>"0-100", :"Minimum Cost"=>"1500", :"Cost Per GB"=>"20"}, {:"Size Slab (IN GB)"=>"100-200", :"Minimum Cost"=>"2000", :"Cost Per GB"=>"13"}, {:"Size Slab (IN GB)"=>"200-300", :"Minimum Cost"=>"2500", :"Cost Per GB"=>"12"}, {:"Size Slab (IN GB)"=>"300-400", :"Minimum Cost"=>"3000", :"Cost Per GB"=>"10"}], "P2"=>[{:"Size Slab (IN GB)"=>"0-200", :"Minimum Cost"=>"1000", :"Cost Per GB"=>"20"}, {:"Size Slab (IN GB)"=>"200-400", :"Minimum Cost"=>"2500", :"Cost Per GB"=>"15"}], "P3"=>[{:"Size Slab (IN GB)"=>"100-200", :"Minimum Cost"=>"800", :"Cost Per GB"=>"25"}, {:"Size Slab (IN GB)"=>"200-600", :"Minimum Cost"=>"1200", :"Cost Per GB"=>"30"}]} 
      values = []
      stripped_row = row.collect(&:strip)
      values << stripped_row[0]
      @h[stripped_row[2]].each do |k, v|
        v.each do |a|
          if find_range(a[:"Size Slab (IN GB)"], stripped_row[1])
            partner = true
            total_cost, delivery = calculate_total_cost(a, stripped_row, k)
          end
        end
      end 
      low_delivery += total_cost
      assigned_capacity += stripped_row[1].to_i
      @h[stripped_row[2]].keys.each do |partner|
        if @capacities_hash[partner].to_i < assigned_capacity
          @h[stripped_row[2]][partner].each do |a|
            if find_range(a[:"Size Slab (IN GB)"], stripped_row[1])
              partner = true
              total_cost, delivery = calculate_total_cost(a, stripped_row, partner)            
              total_delivery += total_cost
              total_delivery = total_delivery - assigned_capacity
            end
          end
        end
      end
      # Create Values to store in output file
      count = 0
      values << true if partner = true
      values << total_cost
      values << delivery
      values.join(' ')
      output << values
    end
    # To create output csv
    create_output_csv(output)
  end
end
