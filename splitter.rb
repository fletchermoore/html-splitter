require 'nokogiri'

class Splitter
  def initialize html=nil
    parse html
  end

  # building the results is a destructive process
  # we will need two trees, and this is easier
  # than trying to copy one because the nodes have
  # pointers everywhere
  def parse html
    return if html.nil?
    @fragment = Nokogiri::HTML.fragment(html)
    @fragment_copy = Nokogiri::HTML.fragment(html)
  end

  def split text, html=nil
    parse html
    first_part text
    second_part text
    [@fragment.to_html, @fragment_copy.to_html]
  end

  def print_tree
    preorder_traverse @fragment do |node|
      puts node.to_html
    end
  end

  def update_content node, delimiter, side
    parts = node.text.split(delimiter, 2)
    if parts.count != 2 then
      node.content = ''
    else
      if side == :keep_left then
        node.content = parts[0]
      else
        node.content = parts[1].lstrip
      end
    end
  end

  # simply remove nodes after the search term is found
  def first_part text
    found = false
    preorder_traverse @fragment do |node|
      if found then
        node.remove
      elsif node.text? then
        if not node.text.index(text).nil? then
          found = true
          update_content node, text, :keep_left
        end
      end
    end
  end

  # do a post order traversal of the dom
  # deleting nodes as you go until you find the
  # target, then stop
  def second_part text
    postorder_traverse @fragment_copy do |node|
      if node.text? then
        if not node.text.index(text).nil? then
          update_content node, text, :keep_right
          return node
        end
      end
      node.remove
    end
  end

  # first the first occurance of text in html text
  # nodes
  def find text
    preorder_traverse @fragment do |node|
      if node.text? then
        if not node.text.index(text).nil? then
          return node
        end
      end
    end
  end
  
  # take a block and a node
  def postorder_traverse node, &block
    if node.children.count > 0 then
      node.children.each do |child|
        postorder_traverse(child, &block)
      end
    end
    block.call(node)
  end

  # take a block and a node
  def preorder_traverse node, &block
    block.call(node)
    if node.children.count > 0 then
      node.children.each do |child|
        preorder_traverse(child, &block)
      end
    end
  end
end
