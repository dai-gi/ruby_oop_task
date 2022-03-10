require_relative "item_manager"
require_relative "ownable"

class Cart
  include ItemManager
  include Ownable

  def initialize(owner)
    self.owner = owner
    @items = []
  end

  def items
    # Cartにとってのitemsは自身の@itemsとしたいため、ItemManagerのitemsメソッドをオーバーライドします。
    super
    # CartインスタンスがItemインスタンスを持つときは、オーナー権限の移譲をさせることなく、自身の@itemsに格納(Cart#add)するだけだからです。
    @items
  end

  def add(item)
    @items << item
  end

  def total_amount
    @items.sum(&:price)
  end

  def check_out
    return if owner.wallet.balance < total_amount
    # ## 要件
    #   - カートの中身（Cart#items）のすべてのアイテムの購入金額が、カートのオーナーのウォレットからアイテムのオーナーのウォレットに移されること。
    self.owner.wallet.withdraw(total_amount)
    seller = items[0].owner
    seller.wallet.deposit(total_amount)

    #   - カートの中身（Cart#items）のすべてのアイテムのオーナー権限が、カートのオーナーに移されること。
    customer = self.owner
    # 購入したアイテムの権限を変更
    items.map do |item|
      item.owner = customer
    end

    #   - カートの中身（Cart#items）が空になること。
    # items.map do |item|
    #   customer.cart.items.map do |cart_item|
    #     if item == cart_item
    #       item.delete
    #     end
    #   end
    # end

    puts "customerの所持アイテム"
    puts items
    puts "カートの所持アイテム"
    puts customer.cart.items

  # ## ヒント
  #   - カートのオーナーのウォレット ==> self.owner.wallet
  #   - アイテムのオーナーのウォレット ==> item.owner.wallet
  #   - お金が移されるということ ==> (？)のウォレットからその分を引き出して、(？)のウォレットにその分を入金するということ
  #   - アイテムのオーナー権限がカートのオーナーに移されること ==> オーナーの書き換え(item.owner = ?)
  end

end
