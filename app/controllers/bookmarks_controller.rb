class BookmarksController < ApplicationController
  def new
    @list = List.find(params[:list_id])
    @bookmark = Bookmark.new
  end

  def create
    @list = List.find(params[:list_id])
    @bookmark = @list.bookmarks.new(bookmark_params)
    if @bookmark.save
      redirect_to @list, notice: "Movie was added to the list."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @list = List.find(params[:list_id])
    @bookmark = @list.bookmarks.find(params[:id])
    @bookmark.destroy
    redirect_to @list, notice: "movie removed from list"
  end


  private

  def bookmark_params
    params.require(:bookmark).permit(:comment, :movie_id)
  end
end
