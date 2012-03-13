class FolderClippingsController < ActionController::Base
  def create
    slug         = params[:folder_clippings][:folder_slug]
    clipping_ids = params[:folder_clippings][:clipping_ids]
    folder       = Folder.find_by_user_and_slug(current_user, slug)
    
    # my-clippings is a "nil" folder
    if (folder.present? || slug == "my-clippings") && clipping_ids.present?
      
      clipping_count = 0
      clipping_ids.each do |id|
        clipping = Clipping.find_by_user_and_id(current_user, id)
        next unless clipping.present?
        
        clipping_count = clipping_count + 1

        clipping.folder_id = folder.present? ? folder.id : nil
        clipping.save
      end
            
      render :json => {:folder => {:name => folder.present? ? folder.name : "my-clippings", 
                                   :slug => slug, 
                                   :doc_count => clipping_count, 
                                   :documents => clipping_ids } }
    elsif ! clipping_ids.present?
      render :text => "No clipping ids present", :status => 400
    else
      render :text => "Unable to find folder with slug '#{slug}'", :status => 404
    end
  end

  def delete
    slug         = params[:folder_clippings][:folder_slug]
    folder       = Folder.find_by_user_and_slug(current_user, slug)

    if params[:folder_clippings][:clipping_ids].present?
      clipping_ids = params[:folder_clippings][:clipping_ids].split(',')
    else
      document_number = params[:folder_clippings][:document_number]
    end

    # my-clippings is a "nil" folder
    if (folder.present? || slug == "my-clippings") && clipping_ids.present?
      clipping_count = 0
      
      clipping_ids.each do |id|
        clipping = Clipping.find_by_user_and_id(current_user, id)
        next unless clipping.present?
        
        clipping_count = clipping_count + 1
        clipping.destroy
      end

      render :json => {:folder => {:name => folder.present? ? folder.name : "my-clippings", 
                                   :slug => slug, 
                                   :doc_count => clipping_count, 
                                   :documents => clipping_ids } }

    elsif (folder.present? || slug == "my-clippings") && document_number.present?
      # there should only be one clipping per document number in each folder - but we don't
      # currently enforce this (but will in the future), this action can only be triggered 
      # from the FR2 article view so we want to delete all references to that document in 
      # the given folder.
      folder_id = folder.present? ? folder.id : nil
      
      clippings = Clipping.find_all_by_folder_id_and_document_number(folder_id, document_number)
      clippings.each{|c| c.destroy}

      render :json => {:folder => {:name => folder.present? ? folder.name : "my-clippings", 
                                   :slug => slug, 
                                   :doc_count => 1, 
                                   :documents => document_number } }
    else
      render :text => "No clipping ids or document number present", :status => 400
    end
  end
end
