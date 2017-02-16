describe 'Expectation Matchers' do

  describe 'equivalence matchers' do

    it 'will match loose equality with #eq' do
      a = "2 cats"
      b = "2 cats"
      expect(a).to eq(b)
      expect(a).to be == b      # synonym for #eq

      c = 17
      d = 17.0
      expect(c).to eq(d)        # different types, but "close enough"
    end

    it 'will match value equality with #eql' do
      a = "2 cats"
      b = "2 cats"
      expect(a).to eql(b)       # just a little stricter

      c = 17
      d = 17.0
      expect(c).not_to eql(d)   # not the same, close doesn't count
    end

    it 'will match identity equality with #equal' do
      a = "2 cats"
      b = "2 cats"
      expect(a).not_to equal(b) # same value, but different object

      c = b
      expect(b).to equal(c)     # same object
      expect(b).to be(c)        # synonym for #equal
    end

  end

  describe 'truthiness matchers' do

    it 'will match true/false' do
      expect(1 < 2).to be(true)       # do not use 'be_true'
      expect(1 > 2).to be(false)      # do not use 'be_false'

      expect('foo').not_to be(true)   # the string is not exactly true
      expect(nil).not_to be(false)    # nil is not exactly false
      expect(0).not_to be(false)      # 0 is not exactly false
    end

    it 'will match truthy/falsey' do
      expect(1 < 2).to be_truthy
      expect(1 > 2).to be_falsey

      expect('foo').to be_truthy      # any value counts as true
      expect(nil).to be_falsey        # nil counts as false
      expect(0).not_to be_falsey      # but 0 is still not falsey enough
    end

    it 'will match nil' do
      expect(nil).to be_nil
      expect(nil).to be(nil)          # either way works

      expect(false).not_to be_nil     # nil only, just like #nil?
      expect(0).not_to be_nil         # nil only, just like #nil?
    end

  end

  describe 'numeric comparison matchers' do

    it 'will match less than/greater than' do
      expect(10).to be > 9
      expect(10).to be >= 10
      expect(10).to be <= 10
      expect(9).to be < 10
    end

    it 'will match numeric ranges' do
      expect(10).to be_between(5, 10).inclusive
      expect(10).not_to be_between(5, 10).exclusive
      expect(10).to be_within(1).of(11)
      expect(5..10).to cover(9)
    end

  end

  describe 'collection matchers' do

    it 'will match arrays' do
      array = [1,2,3]

      expect(array).to include(3)
      expect(array).to include(1,3)

      expect(array).to start_with(1)
      expect(array).to end_with(3)

      expect(array).to match_array([3,2,1])
      expect(array).not_to match_array([1,2])

      expect(array).to contain_exactly(3,2,1)   # similar to match_array
      expect(array).not_to contain_exactly(1,2) # but use individual args
    end

    it 'will match strings' do
      string = 'some string'

      expect(string).to include('ring')
      expect(string).to include('so', 'ring')

      expect(string).to start_with('so')
      expect(string).to end_with('ring')
    end

    it 'will match hashes' do
      hash = {:a => 1, :b => 2, :c => 3}

      expect(hash).to include(:a)
      expect(hash).to include(:a => 1)

      expect(hash).to include(:a => 1, :c => 3)
      expect(hash).to include({:a => 1, :c => 3})

      expect(hash).not_to include({'a' => 1, 'c' => 3})
    end

  end

  describe 'other useful matchers' do

    it 'will match strings with a regex' do
      # This matcher is a good way to "spot check" strings
      string = 'The order has been received.'
      expect(string).to match(/order(.+)received/)

      expect('123').to match(/\d{3}/)
      expect(123).not_to match(/\d{3}/) # only works with strings

      email = 'someone@somewhere.com'
      expect(email).to match(/\A\w+@\w+\.\w{3}\Z/)
    end

    it 'will match object types' do
      expect('test').to be_instance_of(String)
      expect('test').to be_an_instance_of(String) # alias of #be_instance_of

      expect('test').to be_kind_of(String)
      expect('test').to be_a_kind_of(String)  # alias of #be_kind_of
      expect('test').to be_a(String)          # alias of #be_kind_of
      expect([1,2,3]).to be_an(Array)         # alias of #be_kind_of
    end

    it 'will match objects with #respond_to' do
      string = 'test'
      expect(string).to respond_to(:length)
      expect(string).not_to respond_to(:sort)
    end

    it 'will match class instances with #have_attributes' do
      class Car
        attr_accessor :make, :year, :color
      end
      car = Car.new
      car.make = 'Dodge'
      car.year = 2010
      car.color = 'green'

      expect(car).to have_attributes(:color => 'green')
      expect(car).to have_attributes(
                         :make => 'Dodge', :year => 2010, :color => 'green'
                     )
    end

    it 'will match anything with #satisfy' do
      # This is the most flexible matcher
      expect(10).to satisfy do |value|
        (value >= 5) && (value <=10) && (value % 2 == 0)
      end
    end

  end

  describe 'observation matchers' do
    #expect{} not expect()
    it "will match when events change object attributes" do
      #calls test before block and call again after block and verify change
      array = []
      expect { array << 1}.to change(array, :empty?).from(true).to(false)

      class WebsiteHits
        attr_accessor :count
        def initialize; @count = 0; end
        def increment; @count += 1; end
      end
      hits = WebsiteHits.new
      expect { hits.increment }.to change(hits, :count).from(0).to(1)
    end

    it 'will match when events change any values' do
      # calls the test before the block,
      # then again after the block

      # notice the "{}" after "change",
      # can be used on simple variables
      x = 10
      expect { x += 1 }.to change {x}.from(10).to(11)
      expect { x += 1 }.to change {x}.by(1)
      expect { x += 1 }.to change {x}.by_at_least(1)
      expect { x += 1 }.to change {x}.by_at_most(1)

      # notice the "{}" after "change",
      # can contain any block of code
      z = 11
      expect { z += 1 }.to change { z % 3 }.from(2).to(0)

      # Must have a value before the block
      # Must change the value inside the block
    end

    it 'will match when errors are raised' do
      # observes any errors raised by the block

      expect { raise StandardError }.to raise_error
      expect { raise StandardError }.to raise_exception

      expect { 1 / 0 }.to raise_error(ZeroDivisionError)
      expect { 1 / 0 }.to raise_error.with_message("divided by 0")
      expect { 1 / 0 }.to raise_error.with_message(/divided/)

      # Note that the negative form does
      # not accept arguments
      expect { 1 / 1 }.not_to raise_error
    end

    it 'will match when output is generated' do
      # observes output sent to $stdout or $stderr

      expect { print('hello') }.to output.to_stdout
      expect { print('hello') }.to output('hello').to_stdout
      expect { print('hello') }.to output(/ll/).to_stdout

      expect { warn('problem') }.to output(/problem/).to_stderr
    end

    describe 'compound expectations' do

      it 'will match using: and, or, &, |' do
        expect([1,2,3,4]).to start_with(1).and end_with(4)

        expect([1,2,3,4]).to start_with(1) & include(2)

        expect(10 * 10).to be_odd.or be > 50

        array = ['hello', 'goodbye'].shuffle
        expect(array.first).to eq("hello") | eq("goodbye")
      end

    end

    describe 'composing matchers' do
      # some matchers accept matchers as arguments. (new in rspec3)

      it 'will match all collection elements using a matcher' do
        array = [1,2,3]
        expect(array).to all( be < 5 )
      end

      it 'will match by sending matchers as arguments to matchers' do
        string = "hello"
        expect { string = "goodbye" }.to change { string }.
            from( match(/ll/) ).to( match(/oo/) )

        hash = {:a => 1, :b => 2, :c => 3}
        expect(hash).to include(:a => be_odd, :b => be_even, :c => be_odd)
        expect(hash).to include(:a => be > 0, :b => be_within(2).of(4))
      end

      it 'will match using noun-phrase aliases for matchers' do
        # These are built-in aliases that make
        # specs read better by using noun-based
        # phrases instead of verb-based phrases.

        # valid but awkward example
        fruits = ['apple', 'banana', 'cherry']
        expect(fruits).to start_with( start_with('a') ) &
                              include( match(/a.a.a/) ) &
                              end_with( end_with('y') )

        # improved version of the previous example
        # "start_with" becomes "a_string_starting_with"
        # "end_with" becomes "a_string_ending_with"
        # "match" becomes "a_string_matching"
        fruits = ['apple', 'banana', 'cherry']
        expect(fruits).to start_with( a_string_starting_with('a') ) &
                              include( a_string_matching(/a.a.a/) ) &
                              end_with( a_string_ending_with('y') )


        # valid but awkward example
        array = [1,2,3,4]
        expect(array).to start_with( be <= 2 ) |
                             end_with( be_within(1).of(5) )

        # improved version of the previous example
        # "be <= 2" becomes "a_value <= 2"
        # "be_within" becomes "a_value_within"
        array = [1,2,3,4]
        expect(array).to start_with( a_value <= 2 ) |
                             end_with( a_value_within(1).of(5) )
      end

    end

  end

end
