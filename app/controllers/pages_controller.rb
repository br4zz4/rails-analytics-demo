class PagesController < ApplicationController
  def home
  end

  def blog
    @posts = Blog::POSTS
  end

  def post
    @post = Blog::POSTS[params[:slug]] || Blog::POSTS.values.first
  end

  def produtos
  end

  def contato
  end
end