require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products

  def new_product(opts={})
    Product.new(title: opts[:with_title] || 'Produto 1',
      description: opts[:with_description] || 'Este é um produto de teste.',
      image_url: opts[:with_image_url] || 'lorem.png',
      price: opts[:with_price] || 20)
  end

  test "product attributes must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test "product price must be positive" do
    product = new_product
    product.price = -1

    assert product.invalid?
    assert_equal(['must be greater than or equal to 0.01'], product.errors[:price])

    product.price = 0
    assert product.invalid?
    assert_equal(['must be greater than or equal to 0.01'], product.errors[:price])

    product.price = "abc"
    assert product.invalid?
    assert_equal(['is not a number'], product.errors[:price])
  end

  test "image url" do
    ok = %w{ fred.gif fred.jpg fred.png FRED.JPG FRED.jpg
             http://a.b.c/x/y/z/fred.gif }
    bad = %w{ fred.doc fred.gif|more fred.gif.more fred.exe }

    ok.each do |good_url|
      assert(new_product(with_image_url: good_url).valid?, "#{good_url} shouldn't be invalid")
    end

    bad.each do |bad_url|
      assert(new_product(with_image_url: bad_url).invalid?, "#{bad_url} shouldn't be valid")
    end
  end

  test 'product is not valid without a unique title' do
    product = new_product(with_title: products(:ruby).title)
    assert product.invalid?
    assert_equal(['has already been taken'], product.errors[:title])
  end
end
