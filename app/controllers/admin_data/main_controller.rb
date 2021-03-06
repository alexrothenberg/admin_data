class AdminData::MainController  < AdminData::BaseController 

  unloadable

  before_filter :ensure_is_allowed_to_update, 
                :only => [:destroy, :del, :edit, :update, :create]

  before_filter :get_class_from_params,
                :only => [ :table_structure, :show, :destroy, :del,
                           :edit,:new,:update, :create]

  before_filter :get_model_and_verify_it, :only => [:destroy, :del, :edit, :update, :show]
  
  def table_structure
    @page_title = 'table_structure'
    @indexes = []
    if (indexes = ActiveRecord::Base.connection.indexes(@klass.table_name)).any?
      add_index_statements = indexes.map do |index|
        statment_parts = [ ('add_index ' + index.table.inspect) ]
        statment_parts << index.columns.inspect
        statment_parts << (':name => ' + index.name.inspect)
        statment_parts << ':unique => true' if index.unique

        '  ' + statment_parts.join(', ')
      end
      add_index_statements.sort.each { |index| @indexes << index }
    end
  end

  def all_models
    render
  end

  def index
    render
  end

  def show
    @page_title = "#{@klass.name.underscore}:#{@model.id}"
    render
  end

  def destroy
    @klass.send(:destroy, params[:id])
    flash[:success] = 'Record was destroyed'
    redirect_to admin_data_search_path(:klass => @klass.name.underscore)
  end

  def del
    @klass.send(:delete, params[:id])
    flash[:success] = 'Record was deleted'
    redirect_to admin_data_search_path(:klass => @klass.name.underscore)
  end

  def edit
    @page_title = "edit #{@klass.name.underscore}:#{@model.id}"
    render
  end

  def new
    @page_title = "new #{@klass.name.underscore}"
    @model = @klass.send(:new)
  end

  def update
    model_name_underscored = @klass.name.underscore
    model_attrs = params[model_name_underscored]
    if @model.update_attributes(model_attrs)
      flash[:success] = "Record was updated"
      redirect_to admin_data_on_k_path(:id => @model.id, :klass => @klass.name.underscore)
    else
      render :action => 'edit'
    end
  end

  def create
    model_name_underscored = @klass.name.underscore
    model_attrs = params[model_name_underscored]
    @model = @klass.create(model_attrs)

    if @model.errors.any?
      render :action => 'new'
    else
      flash[:success] = "Record was created"
      redirect_to admin_data_on_k_path(:id => @model.id, :klass => @klass.name.underscore)
    end
  end

  private

  def table_name_and_attribute_name(klass,column)
    table_name_and_attribute_name =  klass.table_name+'.'+column.name
  end

  def get_model_and_verify_it
    primary_key = @klass.primary_key
    m = "find_by_#{primary_key}".intern
    @model = @klass.send(m, params[:id])
    if @model.blank?
      render :text => "<h2>#{@klass.name} not found: #{params[:id]}</h2>", :status => :not_found 
    end
  end


end
